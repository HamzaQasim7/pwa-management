import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Remote datasource for Feed Product operations using Firebase Firestore
/// 
/// This datasource handles all Firebase operations for feed products.
/// It's designed to work gracefully when Firebase is not available.
class FeedProductRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  bool _isInitialized = false;

  FeedProductRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get Firestore collection reference for current user
  CollectionReference<Map<String, dynamic>> get _productsRef {
    final userId = _auth.currentUser?.uid ?? 'default';
    return _firestore.collection('users').doc(userId).collection('feedProducts');
  }

  /// Check if Firebase is available
  bool get isAvailable => _isInitialized;

  /// Initialize the remote datasource
  Future<void> init() async {
    try {
      await _firestore.enableNetwork();
      
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        debugPrint('Firebase: Signed in anonymously');
      }
      
      _isInitialized = true;
      debugPrint('FeedProductRemoteDatasource initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase not available for feed products: $e');
    }
  }

  /// Add product to Firebase
  Future<String?> addProduct(Map<String, dynamic> productJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping addProduct');
      return null;
    }
    
    try {
      final docRef = _productsRef.doc(productJson['id']);
      await docRef.set({
        ...productJson,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Product added to Firebase: ${productJson['id']}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding product to Firebase: $e');
      rethrow;
    }
  }

  /// Update product in Firebase
  Future<void> updateProduct(Map<String, dynamic> productJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping updateProduct');
      return;
    }
    
    try {
      final docRef = _productsRef.doc(productJson['id']);
      
      final doc = await docRef.get();
      if (!doc.exists) {
        await addProduct(productJson);
        return;
      }
      
      await docRef.update({
        ...productJson,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Product updated in Firebase: ${productJson['id']}');
    } catch (e) {
      debugPrint('Error updating product in Firebase: $e');
      rethrow;
    }
  }

  /// Delete product from Firebase
  Future<void> deleteProduct(String id) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping deleteProduct');
      return;
    }
    
    try {
      await _productsRef.doc(id).delete();
      debugPrint('Product deleted from Firebase: $id');
    } catch (e) {
      debugPrint('Error deleting product from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch all products from Firebase
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - returning empty list');
      return [];
    }
    
    try {
      final snapshot = await _productsRef
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products from Firebase: $e');
      return [];
    }
  }

  /// Get single product by ID from Firebase
  Future<Map<String, dynamic>?> getProductById(String id) async {
    if (!_isInitialized) return null;
    
    try {
      final doc = await _productsRef.doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return {
        ...data,
        'id': doc.id,
        'firebaseId': doc.id,
        'createdAt': _timestampToIso(data['createdAt']),
        'updatedAt': _timestampToIso(data['updatedAt']),
      };
    } catch (e) {
      debugPrint('Error getting product by ID from Firebase: $e');
      return null;
    }
  }

  /// Watch products stream from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> watchProducts() {
    if (!_isInitialized) return Stream.value([]);
    
    return _productsRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
        };
      }).toList();
    });
  }

  /// Batch add multiple products
  Future<void> batchAddProducts(List<Map<String, dynamic>> products) async {
    if (!_isInitialized || products.isEmpty) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final product in products) {
        final docRef = _productsRef.doc(product['id']);
        batch.set(docRef, {
          ...product,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Batch added ${products.length} products to Firebase');
    } catch (e) {
      debugPrint('Error batch adding products: $e');
      rethrow;
    }
  }

  /// Get products updated after a certain date (for incremental sync)
  Future<List<Map<String, dynamic>>> getProductsUpdatedAfter(DateTime date) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _productsRef
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(date))
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting products updated after $date: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _productsRef
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  /// Get low stock products
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    if (!_isInitialized) return [];
    
    try {
      // Firestore doesn't support comparing two fields directly,
      // so we fetch all and filter locally
      final snapshot = await _productsRef.get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id,
              'firebaseId': doc.id,
              'createdAt': _timestampToIso(data['createdAt']),
              'updatedAt': _timestampToIso(data['updatedAt']),
            };
          })
          .where((p) => (p['stock'] as int) <= (p['lowStockThreshold'] as int))
          .toList();
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }

  /// Convert Firestore Timestamp to ISO string
  String _timestampToIso(dynamic timestamp) {
    if (timestamp == null) return DateTime.now().toIso8601String();
    if (timestamp is Timestamp) {
      return timestamp.toDate().toIso8601String();
    }
    if (timestamp is String) return timestamp;
    return DateTime.now().toIso8601String();
  }
}
