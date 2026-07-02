// lib/services/health_recommendations_service.dart

import '../models/models.dart';

class HealthRecommendationsService {
  static List<NutritionRecommendation> getFruitRecommendations(
    String fruitName,
    Map<String, double> sugarData,
    HealthProfile health,
  ) {
    final recommendations = <NutritionRecommendation>[];

    if (health.conditions.isEmpty || health.conditions.contains(HealthCondition.none)) {
      recommendations.add(
        NutritionRecommendation(
          title: 'Healthy choice',
          advice: '$fruitName is nutritious. Eat fresh as a snack or add to yogurt/smoothies.',
          icon: 'ti-check',
          severity: 'info',
        ),
      );
      return recommendations;
    }

    for (final condition in health.conditions) {
      final recs = _getConditionSpecificRecs(condition, fruitName, sugarData);
      recommendations.addAll(recs);
    }

    return recommendations;
  }

  static List<NutritionRecommendation> getProductRecommendations(
    ProductScan product,
    HealthProfile health,
  ) {
    final recommendations = <NutritionRecommendation>[];

    if (health.conditions.isEmpty || health.conditions.contains(HealthCondition.none)) {
      recommendations.add(
        NutritionRecommendation(
          title: 'Check the label',
          advice:
              'Review the ingredient list and serve size. Choose products with lower sodium when possible.',
          icon: 'ti-info-circle',
          severity: 'info',
        ),
      );
      return recommendations;
    }

    for (final condition in health.conditions) {
      final recs = _getProductConditionRecs(condition, product);
      recommendations.addAll(recs);
    }

    // Check for allergens in profile
    if (health.allergies.isNotEmpty) {
      final intersection = product.allergens
          .where((allergen) => health.allergies
              .any((allergy) => allergen.toLowerCase().contains(allergy.toLowerCase())))
          .toList();
      if (intersection.isNotEmpty) {
        recommendations.insert(
          0,
          NutritionRecommendation(
            title: '⚠️ Allergen detected',
            advice:
                'This product contains: ${intersection.join(", ")}. You listed allergies to: ${health.allergies.join(", ")}.',
            icon: 'ti-alert-triangle',
            severity: 'danger',
          ),
        );
      }
    }

    return recommendations;
  }

  static List<NutritionRecommendation> _getConditionSpecificRecs(
    HealthCondition condition,
    String fruitName,
    Map<String, double> sugarData,
  ) {
    final recs = <NutritionRecommendation>[];
    final totalSugar = sugarData['totalSugarG'] ?? 0.0;

    switch (condition) {
      case HealthCondition.diabetes:
        if (totalSugar > 12) {
          recs.add(
            NutritionRecommendation(
              title: 'High in natural sugars',
              advice:
                  'This $fruitName has ${totalSugar.toStringAsFixed(1)}g sugar per 100g. Eat with protein (nuts, yogurt) to slow blood sugar spike. Limit to 1 serving (100g) per meal.',
              icon: 'ti-alert',
              severity: 'warning',
            ),
          );
        } else {
          recs.add(
            NutritionRecommendation(
              title: 'Good for diabetes management',
              advice: 'Lower sugar content. Pair with protein or fiber to further stabilize blood sugar.',
              icon: 'ti-check',
              severity: 'info',
            ),
          );
        }
        break;

      case HealthCondition.hypertension:
        recs.add(
          NutritionRecommendation(
            title: 'Blood pressure friendly',
            advice:
                '$fruitName is potassium-rich, which helps offset sodium. Excellent choice for hypertension. Eat 1–2 servings daily.',
            icon: 'ti-heart',
            severity: 'info',
          ),
        );
        break;

      case HealthCondition.heartDisease:
        recs.add(
          NutritionRecommendation(
            title: 'Heart-healthy',
            advice:
                '$fruitName is low in saturated fat, high in fiber & antioxidants. Good daily choice. Eat fresh, avoid canned versions with added sugar.',
            icon: 'ti-heart-handshake',
            severity: 'info',
          ),
        );
        break;

      case HealthCondition.kidney:
        recs.add(
          NutritionRecommendation(
            title: 'Check potassium intake',
            advice:
                'Some fruits are high in potassium. If your kidney function is declining, ask your doctor about portion size. Typical limit is 2000mg K/day.',
            icon: 'ti-alert-circle',
            severity: 'warning',
          ),
        );
        break;

      case HealthCondition.celiac:
        recs.add(
          NutritionRecommendation(
            title: 'Naturally gluten-free',
            advice: 'Fresh $fruitName is naturally gluten-free. Safe to eat. Avoid processed versions.',
            icon: 'ti-check',
            severity: 'info',
          ),
        );
        break;

      case HealthCondition.none:
        break;
    }

    return recs;
  }

  static List<NutritionRecommendation> _getProductConditionRecs(
    HealthCondition condition,
    ProductScan product,
  ) {
    final recs = <NutritionRecommendation>[];

    switch (condition) {
      case HealthCondition.diabetes:
        if (product.sugarG > 10) {
          recs.add(
            NutritionRecommendation(
              title: 'High sugar content',
              advice:
                  'This product has ${product.sugarG.toStringAsFixed(1)}g sugar per 100g. Choose lower-sugar alternatives when possible.',
              icon: 'ti-alert',
              severity: 'warning',
            ),
          );
        }
        if (product.carbsG > 30) {
          recs.add(
            NutritionRecommendation(
              title: 'High carbohydrate content',
              advice:
                  'Monitor portion size. Pair with protein to slow digestion and blood sugar rise.',
              icon: 'ti-info-circle',
              severity: 'info',
            ),
          );
        }
        break;

      case HealthCondition.hypertension:
        if (product.sodiumMg > 400) {
          recs.add(
            NutritionRecommendation(
              title: '⚠️ High sodium',
              advice:
                  'This product has ${product.sodiumMg.toStringAsFixed(0)}mg sodium per 100g. Limit intake — try a lower-sodium brand or homemade alternative.',
              icon: 'ti-alert-triangle',
              severity: 'warning',
            ),
          );
        } else if (product.potassiumMg > 200) {
          recs.add(
            NutritionRecommendation(
              title: 'Good potassium source',
              advice: 'Potassium helps counteract sodium effects. This is a good choice.',
              icon: 'ti-heart',
              severity: 'info',
            ),
          );
        }
        break;

      case HealthCondition.heartDisease:
        if (product.saturatedFatG > 5) {
          recs.add(
            NutritionRecommendation(
              title: 'High saturated fat',
              advice:
                  'Limit intake to <5g per 100g. Choose leaner alternatives or consume less frequently.',
              icon: 'ti-alert',
              severity: 'warning',
            ),
          );
        }
        if (product.sodiumMg > 400) {
          recs.add(
            NutritionRecommendation(
              title: 'High sodium',
              advice: 'Too much sodium strains your heart. Choose a lower-sodium version.',
              icon: 'ti-alert',
              severity: 'warning',
            ),
          );
        }
        if (product.fiberG >= 5) {
          recs.add(
            NutritionRecommendation(
              title: 'Good fiber content',
              advice: 'High fiber supports heart health. This is a good choice.',
              icon: 'ti-check',
              severity: 'info',
            ),
          );
        }
        break;

      case HealthCondition.kidney:
        if (product.potassiumMg > 200) {
          recs.add(
            NutritionRecommendation(
              title: 'Monitor potassium',
              advice:
                  'This product has ${product.potassiumMg.toStringAsFixed(0)}mg K per 100g. If your kidney function is compromised, limit portions. Ask your doctor.',
              icon: 'ti-alert-circle',
              severity: 'warning',
            ),
          );
        }
        if (product.proteinG > 15) {
          recs.add(
            NutritionRecommendation(
              title: 'Protein content',
              advice:
                  'Limit daily protein intake. If you have kidney disease, follow your nephrologist\'s guidelines.',
              icon: 'ti-info-circle',
              severity: 'info',
            ),
          );
        }
        if (product.sodiumMg > 400) {
          recs.add(
            NutritionRecommendation(
              title: 'Reduce sodium',
              advice:
                  'Too much sodium stresses kidneys. Choose a lower-sodium brand if possible.',
              icon: 'ti-alert',
              severity: 'warning',
            ),
          );
        }
        break;

      case HealthCondition.celiac:
        // Check if gluten is in ingredients
        final hasGluten = product.ingredients.any((ing) => ing.toLowerCase().contains('gluten') ||
            ing.toLowerCase().contains('wheat') ||
            ing.toLowerCase().contains('barley') ||
            ing.toLowerCase().contains('rye'));
        if (hasGluten) {
          recs.add(
            NutritionRecommendation(
              title: '❌ Contains gluten',
              advice: 'This product has gluten-containing ingredients. Do not consume.',
              icon: 'ti-alert-triangle',
              severity: 'danger',
            ),
          );
        } else {
          recs.add(
            NutritionRecommendation(
              title: 'Gluten-free product',
              advice: 'No gluten detected in ingredients. Check for cross-contamination warnings.',
              icon: 'ti-check',
              severity: 'info',
            ),
          );
        }
        break;

      case HealthCondition.none:
        break;
    }

    return recs;
  }

  static Map<String, dynamic> getDailyServingRecommendation(
    HealthProfile health,
    String itemName,
    double caloriesKcal,
  ) {
    if (health.conditions.isEmpty || health.conditions.contains(HealthCondition.none)) {
      return {
        'servingsPerDay': 2,
        'advice': 'Enjoy up to 2 servings of $itemName per day as part of a balanced diet.',
      };
    }

    final servings = <int>[];
    final advices = <String>[];

    for (final condition in health.conditions) {
      switch (condition) {
        case HealthCondition.diabetes:
          servings.add(1);
          advices.add('1 serving/day (monitor carbs)');
          break;
        case HealthCondition.hypertension:
          servings.add(2);
          advices.add('Up to 2 servings/day (great potassium source)');
          break;
        case HealthCondition.heartDisease:
          servings.add(2);
          advices.add('Up to 2 servings/day (heart-healthy)');
          break;
        case HealthCondition.kidney:
          servings.add(1);
          advices.add('1 serving/day (check potassium limits)');
          break;
        case HealthCondition.celiac:
          servings.add(2);
          advices.add('Up to 2 servings/day if gluten-free');
          break;
        case HealthCondition.none:
          break;
      }
    }

    final minServings = servings.isNotEmpty ? servings.reduce((a, b) => a < b ? a : b) : 2;

    return {
      'servingsPerDay': minServings,
      'advice':
          'Based on your health profile: ${advices.isNotEmpty ? advices.first : "Enjoy in moderation"}',
    };
  }
}
