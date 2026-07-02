// lib/controllers/controllers.dart

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/fruit_analysis_service.dart';
import '../services/health_recommendations_service.dart';
import '../services/openfoodfacts_service.dart';

// ======================== AUTH CONTROLLER ========================
class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthController({required FirebaseAuthService authService}) : _authService = authService {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signup(
        email: email,
        password: password,
        displayName: displayName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}

// ======================== HEALTH CONTROLLER ========================
class HealthController extends ChangeNotifier {
  final FirestoreService _firestoreService;
  HealthProfile? _healthProfile;
  bool _isLoading = false;

  HealthController({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  HealthProfile? get healthProfile => _healthProfile;
  bool get isLoading => _isLoading;

  Future<void> loadHealthProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _healthProfile = await _firestoreService.getHealthProfile(userId) ??
          HealthProfile.empty(userId);
    } catch (e) {
      _healthProfile = HealthProfile.empty(userId);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveHealthProfile(HealthProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.saveHealthProfile(profile);
      _healthProfile = profile;
    } catch (e) {
      // Error handling
    }
    _isLoading = false;
    notifyListeners();
  }

  void updateConditions(List<HealthCondition> conditions) {
    if (_healthProfile != null) {
      _healthProfile = HealthProfile(
        userId: _healthProfile!.userId,
        ageYears: _healthProfile!.ageYears,
        gender: _healthProfile!.gender,
        heightCm: _healthProfile!.heightCm,
        weightKg: _healthProfile!.weightKg,
        conditions: conditions,
        allergies: _healthProfile!.allergies,
        preferredDiets: _healthProfile!.preferredDiets,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateAllergies(List<String> allergies) {
    if (_healthProfile != null) {
      _healthProfile = HealthProfile(
        userId: _healthProfile!.userId,
        ageYears: _healthProfile!.ageYears,
        gender: _healthProfile!.gender,
        heightCm: _healthProfile!.heightCm,
        weightKg: _healthProfile!.weightKg,
        conditions: _healthProfile!.conditions,
        allergies: allergies,
        preferredDiets: _healthProfile!.preferredDiets,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}

// ======================== FRUIT CONTROLLER ========================
class FruitController extends ChangeNotifier {
  final FirestoreService _firestoreService;
  Map<String, dynamic>? _analysisResult;
  List<NutritionRecommendation> _recommendations = [];
  Map<String, dynamic>? _sugarVerdict;
  bool _isAnalyzing = false;
  String? _error;

  FruitController({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Map<String, dynamic>? get analysisResult => _analysisResult;
  List<NutritionRecommendation> get recommendations => _recommendations;
  Map<String, dynamic>? get sugarVerdict => _sugarVerdict;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;

  Future<bool> analyzeFruitImage(
    Uint8List imageBytes,
    String userId,
    HealthProfile health,
  ) async {
    _isAnalyzing = true;
    _error = null;
    _analysisResult = null;
    notifyListeners();

    try {
      final result = await FruitAnalysisService.analyzeFruit(imageBytes);
      if (result == null) {
        _error = 'Could not analyze fruit. Please try another image.';
        _isAnalyzing = false;
        notifyListeners();
        return false;
      }

      _analysisResult = result;

      // Get recommendations
      final fruitName = result['fruit'] as String;
      final sugarData = result['sugar'] as Map<String, double>;
      _recommendations = HealthRecommendationsService.getFruitRecommendations(
        fruitName,
        sugarData,
        health,
      );
      _sugarVerdict = HealthRecommendationsService.getSugarVerdict(
        sugarData['totalSugarG'] ?? 0.0,
        health,
      );

      // Save to Firestore
      final scan = FruitScan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        fruitName: fruitName,
        ripenessScore: (result['ripeness']['score'] as num).toDouble(),
        ripenessLabel: result['ripeness']['label'] as String,
        brix: (result['sugar']['brix'] as num).toDouble(),
        totalSugarG: (result['sugar']['totalSugarG'] as num).toDouble(),
        fructoseG: (result['sugar']['fructoseG'] as num).toDouble(),
        estimatedGI: (result['portion']['gi'] as num).toDouble(),
        servingG: (result['portion']['servingG'] as num).toDouble(),
        scannedAt: DateTime.now(),
      );
      await _firestoreService.saveFruitScan(scan);

      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error analyzing fruit: $e';
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }
}

// ======================== PRODUCT CONTROLLER ========================
class ProductController extends ChangeNotifier {
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  final FirestoreService _firestoreService;
  ProductScan? _productScan;
  List<NutritionRecommendation> _recommendations = [];
  Map<String, dynamic>? _sugarVerdict;
  bool _isLoading = false;
  String? _error;

  ProductController({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  ProductScan? get productScan => _productScan;
  List<NutritionRecommendation> get recommendations => _recommendations;
  Map<String, dynamic>? get sugarVerdict => _sugarVerdict;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> scanBarcode(
    String barcode,
    String userId,
    HealthProfile health,
  ) async {
    _isLoading = true;
    _error = null;
    _productScan = null;
    notifyListeners();

    try {
      // Check if already scanned
      final existing = await _firestoreService.getProductByBarcode(userId, barcode);
      if (existing != null) {
        _productScan = existing;
        _recommendations = HealthRecommendationsService.getProductRecommendations(
          existing,
          health,
        );
        _sugarVerdict = HealthRecommendationsService.getSugarVerdict(
          existing.sugarG,
          health,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Fetch from OpenFoodFacts
      final productData = await _offService.getProductByBarcode(barcode);
      if (productData == null) {
        _error = 'Product not found in database. Please try another barcode.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final scan = ProductScan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        barcode: barcode,
        productName: productData['productName'] as String,
        brand: productData['brand'] as String?,
        imageUrl: productData['imageUrl'] as String?,
        nutrition: productData['nutrition'] as Map<String, dynamic>,
        ingredients: List<String>.from(productData['ingredients'] as List<dynamic>),
        allergens: List<String>.from(productData['allergens'] as List<dynamic>),
        scannedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.saveProductScan(scan);

      _productScan = scan;
      _recommendations = HealthRecommendationsService.getProductRecommendations(
        scan,
        health,
      );
      _sugarVerdict = HealthRecommendationsService.getSugarVerdict(
        scan.sugarG,
        health,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error scanning barcode: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await _offService.searchProducts(query);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = 'Search error: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}
