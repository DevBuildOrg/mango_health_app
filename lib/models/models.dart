// lib/models/models.dart

class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}

class HealthProfile {
  final String userId;
  final int? ageYears;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final List<HealthCondition> conditions;
  final List<String> allergies;
  final List<String> preferredDiets;
  final DateTime updatedAt;

  HealthProfile({
    required this.userId,
    this.ageYears,
    this.gender,
    this.heightCm,
    this.weightKg,
    required this.conditions,
    required this.allergies,
    required this.preferredDiets,
    required this.updatedAt,
  });

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    return weightKg! / ((heightCm! / 100) * (heightCm! / 100));
  }

  factory HealthProfile.empty(String userId) => HealthProfile(
    userId: userId,
    conditions: [],
    allergies: [],
    preferredDiets: [],
    updatedAt: DateTime.now(),
  );

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      userId: json['userId'] ?? '',
      ageYears: json['ageYears'],
      gender: json['gender'],
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((c) => HealthCondition.fromString(c as String))
          .toList() ?? [],
      allergies: List<String>.from(json['allergies'] as List<dynamic>? ?? []),
      preferredDiets: List<String>.from(json['preferredDiets'] as List<dynamic>? ?? []),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'ageYears': ageYears,
    'gender': gender,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'conditions': conditions.map((c) => c.toString()).toList(),
    'allergies': allergies,
    'preferredDiets': preferredDiets,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

enum HealthCondition {
  diabetes,
  hypertension,
  heartDisease,
  kidney,
  celiac,
  none;

  String get display {
    switch (this) {
      case HealthCondition.diabetes: return 'Type 2 Diabetes';
      case HealthCondition.hypertension: return 'Hypertension (High Blood Pressure)';
      case HealthCondition.heartDisease: return 'Heart Disease';
      case HealthCondition.kidney: return 'Kidney Disease';
      case HealthCondition.celiac: return 'Celiac / Gluten Sensitivity';
      case HealthCondition.none: return 'None';
    }
  }

  String get description {
    switch (this) {
      case HealthCondition.diabetes:
        return 'Monitor carbs & sugar; aim for low glycemic load.';
      case HealthCondition.hypertension:
        return 'Watch sodium intake; prefer potassium-rich foods.';
      case HealthCondition.heartDisease:
        return 'Limit saturated fat & sodium; prefer whole grains.';
      case HealthCondition.kidney:
        return 'Monitor potassium, phosphorus, sodium; limit protein.';
      case HealthCondition.celiac:
        return 'Avoid gluten; check all processed foods.';
      case HealthCondition.none:
        return 'No specific dietary restrictions.';
    }
  }

  factory HealthCondition.fromString(String s) {
    switch (s.toLowerCase()) {
      case 'diabetes': return HealthCondition.diabetes;
      case 'hypertension': return HealthCondition.hypertension;
      case 'heartdisease': return HealthCondition.heartDisease;
      case 'kidney': return HealthCondition.kidney;
      case 'celiac': return HealthCondition.celiac;
      default: return HealthCondition.none;
    }
  }

  @override
  String toString() => name;
}

class FruitScan {
  final String id;
  final String userId;
  final String fruitName;
  final double ripenessScore;
  final String ripenessLabel;
  final double brix;
  final double totalSugarG;
  final double fructoseG;
  final double estimatedGI;
  final double servingG;
  final DateTime scannedAt;

  FruitScan({
    required this.id,
    required this.userId,
    required this.fruitName,
    required this.ripenessScore,
    required this.ripenessLabel,
    required this.brix,
    required this.totalSugarG,
    required this.fructoseG,
    required this.estimatedGI,
    required this.servingG,
    required this.scannedAt,
  });

  factory FruitScan.fromJson(Map<String, dynamic> json) {
    return FruitScan(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fruitName: json['fruitName'] ?? 'Unknown',
      ripenessScore: (json['ripenessScore'] as num?)?.toDouble() ?? 0.0,
      ripenessLabel: json['ripenessLabel'] ?? '',
      brix: (json['brix'] as num?)?.toDouble() ?? 0.0,
      totalSugarG: (json['totalSugarG'] as num?)?.toDouble() ?? 0.0,
      fructoseG: (json['fructoseG'] as num?)?.toDouble() ?? 0.0,
      estimatedGI: (json['estimatedGI'] as num?)?.toDouble() ?? 0.0,
      servingG: (json['servingG'] as num?)?.toDouble() ?? 0.0,
      scannedAt: DateTime.parse(json['scannedAt'] ?? DateTime.now().toString()),
    );
  }
}

class ProductScan {
  final String id;
  final String userId;
  final String barcode;
  final String productName;
  final String? brand;
  final String? imageUrl;
  final Map<String, dynamic> nutrition;
  final List<String> ingredients;
  final List<String> allergens;
  final DateTime scannedAt;

  ProductScan({
    required this.id,
    required this.userId,
    required this.barcode,
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.nutrition,
    required this.ingredients,
    required this.allergens,
    required this.scannedAt,
  });

  // Nutrition getters (per 100g if available)
  double get caloriesKcal => (nutrition['energy_kcal'] as num?)?.toDouble() ?? 0.0;
  double get proteinG => (nutrition['protein_g'] as num?)?.toDouble() ?? 0.0;
  double get carbsG => (nutrition['carbohydrates_g'] as num?)?.toDouble() ?? 0.0;
  double get fatG => (nutrition['fat_g'] as num?)?.toDouble() ?? 0.0;
  double get fiberG => (nutrition['fiber_g'] as num?)?.toDouble() ?? 0.0;
  double get sugarG => (nutrition['sugars_g'] as num?)?.toDouble() ?? 0.0;
  double get sodiumMg => (nutrition['sodium_mg'] as num?)?.toDouble() ?? 0.0;
  double get potassiumMg => (nutrition['potassium_mg'] as num?)?.toDouble() ?? 0.0;
  double get saturatedFatG => (nutrition['saturated_fat_g'] as num?)?.toDouble() ?? 0.0;

  factory ProductScan.fromJson(Map<String, dynamic> json) {
    return ProductScan(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      barcode: json['barcode'] ?? '',
      productName: json['productName'] ?? 'Unknown Product',
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      nutrition: json['nutrition'] ?? {},
      ingredients: List<String>.from(json['ingredients'] as List<dynamic>? ?? []),
      allergens: List<String>.from(json['allergens'] as List<dynamic>? ?? []),
      scannedAt: DateTime.parse(json['scannedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'barcode': barcode,
    'productName': productName,
    'brand': brand,
    'imageUrl': imageUrl,
    'nutrition': nutrition,
    'ingredients': ingredients,
    'allergens': allergens,
    'scannedAt': scannedAt.toIso8601String(),
  };
}

class NutritionRecommendation {
  final String title;
  final String advice;
  final String icon;
  final String severity; // 'info', 'warning', 'danger'

  NutritionRecommendation({
    required this.title,
    required this.advice,
    required this.icon,
    required this.severity,
  });
}

class DailyIntake {
  final HealthCondition condition;
  final Map<String, dynamic> limits;

  DailyIntake({required this.condition, required this.limits});

  static DailyIntake forCondition(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.diabetes:
        return DailyIntake(
          condition: condition,
          limits: {
            'carbs_g': 225, // 45g per meal × 5 meals
            'sugar_g': 25, // <25g/day is common recommendation
            'fiber_g': 30, // target at least 30g
            'calories_kcal': 2000,
          },
        );
      case HealthCondition.hypertension:
        return DailyIntake(
          condition: condition,
          limits: {
            'sodium_mg': 1500, // restrictive but effective
            'potassium_mg': 3500, // help offset sodium
            'saturated_fat_g': 13, // <7% of 2000 cal
            'sugar_g': 36, // AHA general limit; watch added sugars too
            'calories_kcal': 2000,
          },
        );
      case HealthCondition.heartDisease:
        return DailyIntake(
          condition: condition,
          limits: {
            'saturated_fat_g': 13,
            'trans_fat_g': 2,
            'cholesterol_mg': 200,
            'sodium_mg': 2000,
            'fiber_g': 30,
            'sugar_g': 25, // AHA recommendation for heart health
          },
        );
      case HealthCondition.kidney:
        return DailyIntake(
          condition: condition,
          limits: {
            'protein_g': 51, // ~0.8g per kg for non-dialysis
            'potassium_mg': 2000,
            'phosphorus_mg': 800,
            'sodium_mg': 2000,
            'sugar_g': 25, // keep simple sugars modest
          },
        );
      case HealthCondition.celiac:
        return DailyIntake(
          condition: condition,
          limits: {
            'gluten_ppm': 0, // absolute zero
            'fiber_g': 25,
            'calories_kcal': 2000,
            'sugar_g': 50, // general guideline; gluten is the real concern
          },
        );
      default:
        return DailyIntake(
          condition: HealthCondition.none,
          limits: {
            'calories_kcal': 2000,
            'carbs_g': 300,
            'protein_g': 50,
            'fat_g': 65,
            'fiber_g': 25,
            'sugar_g': 50, // WHO upper limit for general population
          },
        );
    }
  }
}
