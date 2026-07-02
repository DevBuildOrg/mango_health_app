// lib/views/product_result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';

class ProductResultScreen extends StatelessWidget {
  const ProductResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Analysis')),
      body: Consumer<ProductController>(
        builder: (context, productCtrl, _) {
          final product = productCtrl.productScan;
          final recommendations = productCtrl.recommendations;

          if (product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product image
                if (product.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl!,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.package_2),
                  ),
                const SizedBox(height: 16),

                // Product info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (product.brand != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Brand: ${product.brand}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Barcode: ${product.barcode}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nutrition facts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nutrition (per 100g)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _NutritionRow('Energy', '${product.caloriesKcal.toStringAsFixed(0)} kcal'),
                        _NutritionRow('Protein', '${product.proteinG.toStringAsFixed(1)}g'),
                        _NutritionRow('Carbs', '${product.carbsG.toStringAsFixed(1)}g'),
                        _NutritionRow('Sugar', '${product.sugarG.toStringAsFixed(1)}g'),
                        _NutritionRow('Fat', '${product.fatG.toStringAsFixed(1)}g'),
                        _NutritionRow('Saturated Fat', '${product.saturatedFatG.toStringAsFixed(1)}g'),
                        _NutritionRow('Fiber', '${product.fiberG.toStringAsFixed(1)}g'),
                        _NutritionRow('Sodium', '${product.sodiumMg.toStringAsFixed(0)}mg'),
                        if (product.potassiumMg > 0)
                          _NutritionRow('Potassium', '${product.potassiumMg.toStringAsFixed(0)}mg'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Allergen warnings
                if (product.allergens.isNotEmpty) ...[
                  Card(
                    color: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Contains Allergens',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.allergens.join(', '),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Health recommendations
                const Text(
                  'Health Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (recommendations.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No specific warnings for your health profile.'),
                    ),
                  )
                else
                  ...recommendations.map((rec) => _RecommendationCard(rec: rec)),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Scan Another Product'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  rec.severity == 'danger'
                      ? Icons.error
                      : rec.severity == 'warning'
                          ? Icons.warning
                          : Icons.info_outline,
                  color: borderColors[rec.severity],
                ),
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
