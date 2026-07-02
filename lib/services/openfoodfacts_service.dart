// lib/services/openfoodfacts_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v3';

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$barcode'),
        headers: {
          'User-Agent': 'HealthMangoScanner/1.0 (+https://example.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1 && data['product'] != null) {
          return _parseProduct(data['product'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _parseProduct(Map<String, dynamic> raw) {
    final nutrients = raw['nutriments'] as Map<String, dynamic>? ?? {};

    // Extract per 100g values
    final energyKcal = (nutrients['energy-kcal'] as num?)?.toDouble() ??
        ((nutrients['energy-kcal_100g'] as num?)?.toDouble());
    final protein = (nutrients['proteins'] as num?)?.toDouble() ??
        ((nutrients['proteins_100g'] as num?)?.toDouble());
    final carbs = (nutrients['carbohydrates'] as num?)?.toDouble() ??
        ((nutrients['carbohydrates_100g'] as num?)?.toDouble());
    final fat = (nutrients['fat'] as num?)?.toDouble() ??
        ((nutrients['fat_100g'] as num?)?.toDouble());
    final fiber = (nutrients['fiber'] as num?)?.toDouble() ??
        ((nutrients['fiber_100g'] as num?)?.toDouble());
    final sugars = (nutrients['sugars'] as num?)?.toDouble() ??
        ((nutrients['sugars_100g'] as num?)?.toDouble());
    final sodium = (nutrients['sodium'] as num?)?.toDouble() ??
        ((nutrients['sodium_100g'] as num?)?.toDouble());
    final saturatedFat = (nutrients['saturated-fat'] as num?)?.toDouble() ??
        ((nutrients['saturated-fat_100g'] as num?)?.toDouble());

    // Extract allergens
    final allergensStr = raw['allergens'] as String? ?? '';
    final allergens = allergensStr
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    // Extract ingredients
    final ingredientsList = (raw['ingredients'] as List<dynamic>?)
        ?.map((i) => (i as Map<String, dynamic>)['text'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList() ?? [];

    return {
      'productName': raw['product_name'] ?? 'Unknown Product',
      'brand': raw['brands'] ?? 'Unknown Brand',
      'imageUrl': raw['image_url'] ?? raw['image_front_url'],
      'nutrition': {
        'energy_kcal': energyKcal,
        'protein_g': protein,
        'carbohydrates_g': carbs,
        'fat_g': fat,
        'fiber_g': fiber,
        'sugars_g': sugars,
        'sodium_mg': sodium != null ? sodium * 1000 : null, // convert from g to mg
        'saturated_fat_g': saturatedFat,
      },
      'ingredients': ingredientsList,
      'allergens': allergens,
    };
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cgi/search.pl')
            .replace(queryParameters: {'q': query, 'format': 'json', 'page_size': '10'}),
        headers: {
          'User-Agent': 'HealthMangoScanner/1.0 (+https://example.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final products = (data['products'] as List<dynamic>?) ?? [];
        return products
            .take(5)
            .map((p) => _parseProduct(p as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
