// lib/views/fruit_result_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import 'widgets/sweetness_verdict_card.dart';

class FruitResultScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const FruitResultScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fruit Analysis')),
      body: Consumer<FruitController>(
        builder: (context, fruitCtrl, _) {
          final result = fruitCtrl.analysisResult;
          final recommendations = fruitCtrl.recommendations;

          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(imageBytes, height: 200, fit: BoxFit.cover),
                ),
                const SizedBox(height: 24),

                // Fruit name & ripeness
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['fruit'] as String,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _RipenessGauge(
                          score: result['ripeness']['score'] as double,
                          label: result['ripeness']['label'] as String,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // "Is this too sweet for me?" — the answer people actually want first
                if (fruitCtrl.sugarVerdict != null) ...[
                  SweetnessVerdictCard(verdict: fruitCtrl.sugarVerdict!),
                  const SizedBox(height: 16),
                ],

                // Sweetness card (details, for anyone who wants the numbers)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sugar details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _StatRow('Brix (Sugar %):', '${result['sugar']['brix']}°'),
                        _StatRow(
                          'Total sugar (per 100g):',
                          '${result['sugar']['totalSugarG']}g',
                        ),
                        _StatRow(
                          'Fructose:',
                          '${result['sugar']['fructoseG']}g',
                        ),
                        _StatRow(
                          'Estimated GI:',
                          '${result['portion']['gi'].toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Diabetic/Health portion
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recommended Portion',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${result['portion']['servingG'].toStringAsFixed(0)} grams',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFA000)),
                        ),
                        Text(
                          '(≈ ${result['portion']['cups']} cup)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Based on glycemic load ≤ 10 (low GL target)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Health recommendations
                const Text(
                  'Health Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (recommendations.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No specific restrictions for your profile.'),
                    ),
                  )
                else
                  ...recommendations.map((rec) => _RecommendationCard(rec: rec)),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFFFA000),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Scan Another Fruit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RipenessGauge extends StatelessWidget {
  final double score;
  final String label;

  const _RipenessGauge({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${score.toStringAsFixed(0)}/100'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              score < 30
                  ? Colors.green
                  : score < 70
                      ? Colors.orange
                      : Colors.brown,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final dynamic rec;

  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'info': Colors.blue[50],
      'warning': Colors.orange[50],
      'danger': Colors.red[50],
    };
    final borderColors = {
      'info': Colors.blue[200],
      'warning': Colors.orange[200],
      'danger': Colors.red[200],
    };

    return Card(
      color: colors[rec.severity],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColors[rec.severity]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: borderColors[rec.severity]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(rec.advice, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
