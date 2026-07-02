// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Health Profile operations
  Future<void> saveHealthProfile(HealthProfile profile) async {
    await _db.collection('users').doc(profile.userId).collection('health').doc('profile').set(
      profile.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<HealthProfile?> getHealthProfile(String userId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('health')
          .doc('profile')
          .get();
      if (!doc.exists) return null;
      return HealthProfile.fromJson(doc.data() ?? {});
    } catch (e) {
      return null;
    }
  }

  Stream<HealthProfile?> watchHealthProfile(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('health')
        .doc('profile')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return HealthProfile.fromJson(doc.data() ?? {});
    });
  }

  // Fruit scan history
  Future<void> saveFruitScan(FruitScan scan) async {
    await _db
        .collection('users')
        .doc(scan.userId)
        .collection('scans')
        .doc(scan.id)
        .set({
      'fruitName': scan.fruitName,
      'ripenessScore': scan.ripenessScore,
      'ripenessLabel': scan.ripenessLabel,
      'brix': scan.brix,
      'totalSugarG': scan.totalSugarG,
      'fructoseG': scan.fructoseG,
      'estimatedGI': scan.estimatedGI,
      'servingG': scan.servingG,
      'scannedAt': scan.scannedAt,
    });
  }

  Future<List<FruitScan>> getFruitScans(String userId, {int limit = 20}) async {
    final docs = await _db
        .collection('users')
        .doc(userId)
        .collection('scans')
        .where('fruitName', isNotEqualTo: null) // only fruit scans
        .orderBy('fruitName')
        .orderBy('scannedAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => FruitScan.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Product scan history
  Future<void> saveProductScan(ProductScan scan) async {
    await _db
        .collection('users')
        .doc(scan.userId)
        .collection('products')
        .doc(scan.id)
        .set(scan.toJson());
  }

  Future<List<ProductScan>> getProductScans(String userId, {int limit = 20}) async {
    final docs = await _db
        .collection('users')
        .doc(userId)
        .collection('products')
        .orderBy('scannedAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => ProductScan.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Search product by barcode
  Future<ProductScan?> getProductByBarcode(String userId, String barcode) async {
    final docs = await _db
        .collection('users')
        .doc(userId)
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (docs.docs.isEmpty) return null;
    return ProductScan.fromJson({...docs.docs.first.data(), 'id': docs.docs.first.id});
  }
}
