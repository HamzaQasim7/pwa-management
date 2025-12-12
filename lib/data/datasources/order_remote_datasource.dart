import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Remote datasource for Order operations using Firebase Firestore
/// 
/// This datasource handles all Firebase operations for orders.
/// It's designed to work gracefully when Firebase is not available.
class OrderRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  bool _isInitialized = false;

  OrderRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get Firestore collection reference for current user
  CollectionReference<Map<String, dynamic>> get _ordersRef {
    final userId = _auth.currentUser?.uid ?? 'default';
    return _firestore.collection('users').doc(userId).collection('orders');
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
      debugPrint('OrderRemoteDatasource initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase not available for orders: $e');
    }
  }

  /// Add order to Firebase
  Future<String?> addOrder(Map<String, dynamic> orderJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping addOrder');
      return null;
    }
    
    try {
      final docRef = _ordersRef.doc(orderJson['id']);
      await docRef.set({
        ...orderJson,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Order added to Firebase: ${orderJson['id']}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding order to Firebase: $e');
      rethrow;
    }
  }

  /// Update order in Firebase
  Future<void> updateOrder(Map<String, dynamic> orderJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping updateOrder');
      return;
    }
    
    try {
      final docRef = _ordersRef.doc(orderJson['id']);
      
      final doc = await docRef.get();
      if (!doc.exists) {
        await addOrder(orderJson);
        return;
      }
      
      await docRef.update({
        ...orderJson,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Order updated in Firebase: ${orderJson['id']}');
    } catch (e) {
      debugPrint('Error updating order in Firebase: $e');
      rethrow;
    }
  }

  /// Delete order from Firebase
  Future<void> deleteOrder(String id) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping deleteOrder');
      return;
    }
    
    try {
      await _ordersRef.doc(id).delete();
      debugPrint('Order deleted from Firebase: $id');
    } catch (e) {
      debugPrint('Error deleting order from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch all orders from Firebase
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - returning empty list');
      return [];
    }
    
    try {
      final snapshot = await _ordersRef
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
      debugPrint('Error fetching orders from Firebase: $e');
      return [];
    }
  }

  /// Get single order by ID from Firebase
  Future<Map<String, dynamic>?> getOrderById(String id) async {
    if (!_isInitialized) return null;
    
    try {
      final doc = await _ordersRef.doc(id).get();
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
      debugPrint('Error getting order by ID from Firebase: $e');
      return null;
    }
  }

  /// Watch orders stream from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> watchOrders() {
    if (!_isInitialized) return Stream.value([]);
    
    return _ordersRef
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

  /// Batch add multiple orders
  Future<void> batchAddOrders(List<Map<String, dynamic>> orders) async {
    if (!_isInitialized || orders.isEmpty) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final order in orders) {
        final docRef = _ordersRef.doc(order['id']);
        batch.set(docRef, {
          ...order,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Batch added ${orders.length} orders to Firebase');
    } catch (e) {
      debugPrint('Error batch adding orders: $e');
      rethrow;
    }
  }

  /// Get orders updated after a certain date (for incremental sync)
  Future<List<Map<String, dynamic>>> getOrdersUpdatedAfter(DateTime date) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _ordersRef
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
      debugPrint('Error getting orders updated after $date: $e');
      return [];
    }
  }

  /// Get orders by customer
  Future<List<Map<String, dynamic>>> getOrdersByCustomer(String customerId) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _ordersRef
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
      debugPrint('Error getting orders by customer: $e');
      return [];
    }
  }

  /// Get orders by payment status
  Future<List<Map<String, dynamic>>> getOrdersByPaymentStatus(String status) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _ordersRef
          .where('paymentStatus', isEqualTo: status)
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
      debugPrint('Error getting orders by payment status: $e');
      return [];
    }
  }

  /// Get orders by date range
  Future<List<Map<String, dynamic>>> getOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _ordersRef
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
      debugPrint('Error getting orders by date range: $e');
      return [];
    }
  }

  /// Get pending orders
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    return getOrdersByPaymentStatus('Pending');
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
