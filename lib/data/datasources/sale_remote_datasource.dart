import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Remote datasource for Sale operations using Firebase Firestore
/// 
/// This datasource handles all Firebase operations for sales.
/// It's designed to work gracefully when Firebase is not available.
class SaleRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  bool _isInitialized = false;

  SaleRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get Firestore collection reference for current user
  CollectionReference<Map<String, dynamic>> get _salesRef {
    final userId = _auth.currentUser?.uid ?? 'default';
    return _firestore.collection('users').doc(userId).collection('sales');
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
      debugPrint('SaleRemoteDatasource initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase not available for sales: $e');
    }
  }

  /// Add sale to Firebase
  Future<String?> addSale(Map<String, dynamic> saleJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping addSale');
      return null;
    }
    
    try {
      final docRef = _salesRef.doc(saleJson['id']);
      await docRef.set({
        ...saleJson,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Sale added to Firebase: ${saleJson['id']}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding sale to Firebase: $e');
      rethrow;
    }
  }

  /// Update sale in Firebase
  Future<void> updateSale(Map<String, dynamic> saleJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping updateSale');
      return;
    }
    
    try {
      final docRef = _salesRef.doc(saleJson['id']);
      
      final doc = await docRef.get();
      if (!doc.exists) {
        await addSale(saleJson);
        return;
      }
      
      await docRef.update({
        ...saleJson,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Sale updated in Firebase: ${saleJson['id']}');
    } catch (e) {
      debugPrint('Error updating sale in Firebase: $e');
      rethrow;
    }
  }

  /// Delete sale from Firebase
  Future<void> deleteSale(String id) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping deleteSale');
      return;
    }
    
    try {
      await _salesRef.doc(id).delete();
      debugPrint('Sale deleted from Firebase: $id');
    } catch (e) {
      debugPrint('Error deleting sale from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch all sales from Firebase
  Future<List<Map<String, dynamic>>> fetchSales() async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - returning empty list');
      return [];
    }
    
    try {
      final snapshot = await _salesRef
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
          'date': _timestampToIso(data['date']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching sales from Firebase: $e');
      return [];
    }
  }

  /// Get single sale by ID from Firebase
  Future<Map<String, dynamic>?> getSaleById(String id) async {
    if (!_isInitialized) return null;
    
    try {
      final doc = await _salesRef.doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return {
        ...data,
        'id': doc.id,
        'firebaseId': doc.id,
        'createdAt': _timestampToIso(data['createdAt']),
        'updatedAt': _timestampToIso(data['updatedAt']),
        'date': _timestampToIso(data['date']),
      };
    } catch (e) {
      debugPrint('Error getting sale by ID from Firebase: $e');
      return null;
    }
  }

  /// Watch sales stream from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> watchSales() {
    if (!_isInitialized) return Stream.value([]);
    
    return _salesRef
        .orderBy('date', descending: true)
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
          'date': _timestampToIso(data['date']),
        };
      }).toList();
    });
  }

  /// Batch add multiple sales
  Future<void> batchAddSales(List<Map<String, dynamic>> sales) async {
    if (!_isInitialized || sales.isEmpty) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final sale in sales) {
        final docRef = _salesRef.doc(sale['id']);
        batch.set(docRef, {
          ...sale,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Batch added ${sales.length} sales to Firebase');
    } catch (e) {
      debugPrint('Error batch adding sales: $e');
      rethrow;
    }
  }

  /// Get sales updated after a certain date (for incremental sync)
  Future<List<Map<String, dynamic>>> getSalesUpdatedAfter(DateTime date) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _salesRef
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
          'date': _timestampToIso(data['date']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales updated after $date: $e');
      return [];
    }
  }

  /// Get sales by customer
  Future<List<Map<String, dynamic>>> getSalesByCustomer(String customerId) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _salesRef
          .where('customerId', isEqualTo: customerId)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
          'date': _timestampToIso(data['date']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales by customer: $e');
      return [];
    }
  }

  /// Get sales by payment method
  Future<List<Map<String, dynamic>>> getSalesByPaymentMethod(String method) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _salesRef
          .where('paymentMethod', isEqualTo: method)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
          'date': _timestampToIso(data['date']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales by payment method: $e');
      return [];
    }
  }

  /// Get sales by date range
  Future<List<Map<String, dynamic>>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _salesRef
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
          'date': _timestampToIso(data['date']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales by date range: $e');
      return [];
    }
  }

  /// Get today's sales
  Future<List<Map<String, dynamic>>> getTodaysSales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSalesByDateRange(startOfDay, endOfDay);
  }

  /// Get sales statistics for a date range
  Future<Map<String, dynamic>> getSalesStatistics(
    DateTime start,
    DateTime end,
  ) async {
    if (!_isInitialized) {
      return {
        'totalSales': 0,
        'totalRevenue': 0.0,
        'totalProfit': 0.0,
        'averageOrderValue': 0.0,
      };
    }
    
    try {
      final sales = await getSalesByDateRange(start, end);
      
      double totalRevenue = 0;
      double totalProfit = 0;
      
      for (final sale in sales) {
        totalRevenue += (sale['total'] as num).toDouble();
        totalProfit += (sale['profit'] as num?)?.toDouble() ?? 0;
      }
      
      return {
        'totalSales': sales.length,
        'totalRevenue': totalRevenue,
        'totalProfit': totalProfit,
        'averageOrderValue': sales.isNotEmpty ? totalRevenue / sales.length : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting sales statistics: $e');
      return {
        'totalSales': 0,
        'totalRevenue': 0.0,
        'totalProfit': 0.0,
        'averageOrderValue': 0.0,
      };
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
