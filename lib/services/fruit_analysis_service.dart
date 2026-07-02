// lib/services/fruit_analysis_service.dart

import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../models/models.dart';

class FruitAnalysisService {
  static Future<Map<String, dynamic>?> analyzeFruit(Uint8List bytes) async {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = decoded.width > 400
          ? img.copyResize(decoded, width: 400)
          : decoded;

      final stats = _computeStats(resized);
      if (stats == null) return null;

      final fruit = _identifyFruit(stats);
      final ripeness = _ripenessScore(stats);
      final sugar = _estimateSugar(ripeness['score'] as double, ripeness['label'] as String);
      final portion = _diabeticPortion(ripeness['score'] as double, sugar);

      return {
        'fruit': fruit,
        'ripeness': ripeness,
        'sugar': sugar,
        'portion': portion,
      };
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? _computeStats(img.Image image) {
    final w = image.width;
    final h = image.height;

    final mask = List.generate(h, (_) => List.filled(w, false));
    int maskCount = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = image.getPixel(x, y);
        final hsv = _rgbToHsv(p.r.toDouble(), p.g.toDouble(), p.b.toDouble());
        if (hsv[1] > 0.157 && hsv[2] > 0.118 && hsv[2] < 0.98) {
          mask[y][x] = true;
          maskCount++;
        }
      }
    }

    if (maskCount < 0.05 * w * h) {
      final y0 = (h * 0.2).floor();
      final y1 = (h * 0.8).ceil();
      final x0 = (w * 0.2).floor();
      final x1 = (w * 0.8).ceil();
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          mask[y][x] = (y >= y0 && y < y1 && x >= x0 && x < x1);
        }
      }
    }

    final List<double> hues = [], sats = [], vals = [];
    int grn = 0, yel = 0, brn = 0;
    int minX = w, maxX = 0, minY = h, maxY = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (!mask[y][x]) continue;
        final p = image.getPixel(x, y);
        final hsv = _rgbToHsv(p.r.toDouble(), p.g.toDouble(), p.b.toDouble());
        hues.add(hsv[0]);
        sats.add(hsv[1]);
        vals.add(hsv[2]);
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        if (hsv[0] >= 70 && hsv[0] <= 160) grn++;
        if (hsv[0] >= 20 && hsv[0] < 70) yel++;
        if (hsv[0] < 40 && hsv[2] < 0.45) brn++;
      }
    }

    if (hues.isEmpty) return null;

    double sumSin = 0, sumCos = 0;
    for (final h in hues) {
      final rad = h * pi / 180.0;
      sumSin += sin(rad);
      sumCos += cos(rad);
    }
    double meanHue = atan2(sumSin / hues.length, sumCos / hues.length) * 180 / pi;
    if (meanHue < 0) meanHue += 360;

    final meanSat = sats.reduce((a, b) => a + b) / sats.length;
    final meanVal = vals.reduce((a, b) => a + b) / vals.length;
    final aspectRatio = (maxY - minY) == 0 ? 1.0 : (maxX - minX) / (maxY - minY).toDouble();

    return {
      'meanHue': meanHue,
      'meanSat': meanSat,
      'meanVal': meanVal,
      'greenPct': grn / hues.length,
      'yellowPct': yel / hues.length,
      'brownPct': brn / hues.length,
      'aspectRatio': aspectRatio,
    };
  }

  static List<double> _rgbToHsv(double r, double g, double b) {
    r /= 255.0;
    g /= 255.0;
    b /= 255.0;
    final maxV = max(r, max(g, b));
    final minV = min(r, min(g, b));
    final delta = maxV - minV;

    double h;
    if (delta == 0) {
      h = 0;
    } else if (maxV == r) {
      h = 60 * (((g - b) / delta) % 6);
    } else if (maxV == g) {
      h = 60 * (((b - r) / delta) + 2);
    } else {
      h = 60 * (((r - g) / delta) + 4);
    }
    if (h < 0) h += 360;
    return [h, maxV == 0 ? 0.0 : delta / maxV, maxV];
  }

  static String _identifyFruit(Map<String, dynamic> stats) {
    final h = stats['meanHue'] as double;
    final r = stats['aspectRatio'] as double;

    final sigs = [
      {'name': 'Mango', 'hMin': 25.0, 'hMax': 160.0, 'rMin': 1.1, 'rMax': 1.9},
      {'name': 'Banana', 'hMin': 40.0, 'hMax': 65.0, 'rMin': 2.0, 'rMax': 4.0},
      {'name': 'Apple', 'hMin': 0.0, 'hMax': 20.0, 'rMin': 0.85, 'rMax': 1.2},
      {'name': 'Apple', 'hMin': 80.0, 'hMax': 160.0, 'rMin': 0.85, 'rMax': 1.2},
      {'name': 'Orange', 'hMin': 15.0, 'hMax': 45.0, 'rMin': 0.85, 'rMax': 1.2},
    ];

    double best = -1;
    String bestName = 'Mango';

    for (final sig in sigs) {
      final rs = (double v, double lo, double hi) {
        if (v >= lo && v <= hi) return 1.0;
        final span = (hi - lo).abs().clamp(1.0, 360.0);
        return (1.0 - (v < lo ? lo - v : v - hi) / span).clamp(0.0, 1.0);
      };

      final score = rs(h, sig['hMin'] as double, sig['hMax'] as double) * 0.65 +
          rs(r, sig['rMin'] as double, sig['rMax'] as double) * 0.35;

      if (score > best) {
        best = score;
        bestName = sig['name'] as String;
      }
    }

    return bestName;
  }

  static Map<String, dynamic> _ripenessScore(Map<String, dynamic> stats) {
    const greenHue = 140.0;
    const ripeHue = 45.0;
    final hue = stats['meanHue'] as double;
    final brownPct = stats['brownPct'] as double;

    final hueClamped = hue.clamp(ripeHue, greenHue);
    final baseScore = (greenHue - hueClamped) / (greenHue - ripeHue) * 100.0;
    final spotBonus = (brownPct * 150.0).clamp(0.0, 30.0);
    final score = (baseScore + spotBonus).clamp(0.0, 100.0);

    String label;
    if (brownPct > 0.18) {
      label = 'Overripe';
    } else if (score < 20) {
      label = 'Unripe (Green)';
    } else if (score < 55) {
      label = 'Turning Ripe';
    } else if (score < 85) {
      label = 'Ripe';
    } else {
      label = 'Very Ripe';
    }

    return {
      'score': double.parse(score.toStringAsFixed(1)),
      'label': label,
    };
  }

  static Map<String, double> _estimateSugar(double score, String label) {
    double brix = 7.0 + (score / 100.0) * 13.0;
    if (label == 'Overripe') brix += 2.0;
    brix = min(brix, 22.0);

    final totalSugar = brix * 0.85;
    final fructoseFraction = 0.20 + (score / 100.0) * 0.15;
    final fructose = totalSugar * fructoseFraction;

    return {
      'brix': double.parse(brix.toStringAsFixed(1)),
      'totalSugarG': double.parse(totalSugar.toStringAsFixed(1)),
      'fructoseG': double.parse(fructose.toStringAsFixed(1)),
      'fructoseFraction': double.parse(fructoseFraction.toStringAsFixed(2)),
    };
  }

  static Map<String, double> _diabeticPortion(double score, Map<String, double> sugar) {
    final gi = 41 + (score / 100.0) * 19;
    final carbs = sugar['totalSugarG']! + 1.5;
    final serving = (10.0 * 10000.0) / (gi * carbs);

    return {
      'gi': double.parse(gi.toStringAsFixed(1)),
      'carbsPer100g': carbs.roundToDouble(),
      'servingG': double.parse(serving.toStringAsFixed(0)),
      'cups': double.parse((serving / 165.0).toStringAsFixed(2)),
      'fractionOfFruit': double.parse((serving / 150.0).toStringAsFixed(2)),
    };
  }
}
