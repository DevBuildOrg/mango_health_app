// lib/views/widgets/sweetness_verdict_card.dart
//
// A big, plain-language card that answers the #1 question people have:
// "Is this too sweet for ME?"
//
// Shows a traffic-light color, a one-line verdict, how much sugar is in
// the item, and the person's recommended daily sugar limit — all at a
// glance, no jargon.

import 'package:flutter/material.dart';

class SweetnessVerdictCard extends StatelessWidget {
  /// Result of HealthRecommendationsService.getSugarVerdict(...)
  final Map<String, dynamic> verdict;

  const SweetnessVerdictCard({super.key, required this.verdict});

  @override
  Widget build(BuildContext context) {
    final level = verdict['level'] as String; // good | moderate | high
    final sugarG = (verdict['sugarG'] as num).toDouble();
    final dailyLimitG = (verdict['dailyLimitG'] as num).toDouble();
    final percent = (verdict['percentOfLimit'] as num).toDouble();
    final verdictText = verdict['verdict'] as String;
    final detail = verdict['detail'] as String;
    final emoji = verdict['emoji'] as String;

    final colors = _colorsFor(level);

    return Card(
      elevation: 0,
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    verdictText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: TextStyle(fontSize: 14, color: colors.text.withOpacity(0.85)),
            ),
            const SizedBox(height: 16),

            // Plain-language sugar amount
            Text(
              '${sugarG.toStringAsFixed(1)}g sugar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),

            // Progress bar toward daily limit
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.6),
                valueColor: AlwaysStoppedAnimation<Color>(colors.bar),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percent.toStringAsFixed(0)}% of your recommended daily sugar limit (${dailyLimitG.toStringAsFixed(0)}g/day)',
              style: TextStyle(fontSize: 12, color: colors.text.withOpacity(0.75)),
            ),
          ],
        ),
      ),
    );
  }

  _VerdictColors _colorsFor(String level) {
    switch (level) {
      case 'good':
        return _VerdictColors(
          background: const Color(0xFFE8F5E9),
          border: const Color(0xFF66BB6A),
          text: const Color(0xFF1B5E20),
          bar: const Color(0xFF43A047),
        );
      case 'moderate':
        return _VerdictColors(
          background: const Color(0xFFFFF8E1),
          border: const Color(0xFFFFB300),
          text: const Color(0xFF8D5B00),
          bar: const Color(0xFFFFA000),
        );
      case 'high':
      default:
        return _VerdictColors(
          background: const Color(0xFFFFEBEE),
          border: const Color(0xFFE53935),
          text: const Color(0xFFB71C1C),
          bar: const Color(0xFFE53935),
        );
    }
  }
}

class _VerdictColors {
  final Color background;
  final Color border;
  final Color text;
  final Color bar;

  _VerdictColors({
    required this.background,
    required this.border,
    required this.text,
    required this.bar,
  });
}
