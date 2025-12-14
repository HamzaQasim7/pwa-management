import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/firebase_auth_service.dart';

/// Remote datasource for Customer operations using Firebase Firestore
/// 
/// This datasource handles all Firebase operations for customers.
/// It's designed to work gracefully when Firebase is not available.
class CustomerRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseAuthService _authService;
  
  bool _isInitialized = false;

  CustomerRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseAuthService? authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _authService = authService ?? FirebaseAuthService();

  /// Get Firestore collection reference for current user
  CollectionReference<Map<String, dynamic>> get _customersRef {
    final userId = _auth.currentUser?.uid ?? 'default';
    return _firestore.collection('users').doc(userId).collection('customers');
  }

  /// Check if Firebase is available
  bool get isAvailable => _isInitialized;

  /// Initialize the remote datasource
  Future<void> init() async {
    try {
      // Try to enable network to verify Firebase is available
      await _firestore.enableNetwork();
      
      // Ensure admin authentication
      final authenticated = await _authService.ensureAuthenticated();
      if (!authenticated) {
        debugPrint('Firebase: Failed to authenticate admin');
        _isInitialized = false;
        return;
      }
      
      _isInitialized = true;
      debugPrint('CustomerRemoteDatasource initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase not available for customers: $e');
    }
  }

  /// Add customer to Firebase
  Future<String?> addCustomer(Map<String, dynamic> customerJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping addCustomer');
      return null;
    }
    
    try {
      final docRef = _customersRef.doc(customerJson['id']);
      await docRef.set({
        ...customerJson,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Customer added to Firebase: ${customerJson['id']}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding customer to Firebase: $e');
      rethrow;
    }
  }

  /// Update customer in Firebase
  Future<void> updateCustomer(Map<String, dynamic> customerJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping updateCustomer');
      return;
    }
    
    try {
      final docRef = _customersRef.doc(customerJson['id']);
      
      // Check if document exists
      final doc = await docRef.get();
      if (!doc.exists) {
        // Document doesn't exist, create it
        await addCustomer(customerJson);
        return;
      }
      
      await docRef.update({
        ...customerJson,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Customer updated in Firebase: ${customerJson['id']}');
    } catch (e) {
      debugPrint('Error updating customer in Firebase: $e');
      rethrow;
    }
  }

  /// Delete customer from Firebase
  Future<void> deleteCustomer(String id) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping deleteCustomer');
      return;
    }
    
    try {
      await _customersRef.doc(id).delete();
      debugPrint('Customer deleted from Firebase: $id');
    } catch (e) {
      debugPrint('Error deleting customer from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch all customers from Firebase
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - returning empty list');
      return [];
    }
    
    try {
      final snapshot = await _customersRef
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          // Convert Timestamps to ISO strings for local storage
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching customers from Firebase: $e');
      return [];
    }
  }

  /// Get single customer by ID from Firebase
  Future<Map<String, dynamic>?> getCustomerById(String id) async {
    if (!_isInitialized) return null;
    
    try {
      final doc = await _customersRef.doc(id).get();
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
      debugPrint('Error getting customer by ID from Firebase: $e');
      return null;
    }
  }

  /// Watch customers stream from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> watchCustomers() {
    if (!_isInitialized) return Stream.value([]);
    
    return _customersRef
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

  /// Batch add multiple customers
  Future<void> batchAddCustomers(List<Map<String, dynamic>> customers) async {
    if (!_isInitialized || customers.isEmpty) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final customer in customers) {
        final docRef = _customersRef.doc(customer['id']);
        batch.set(docRef, {
          ...customer,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Batch added ${customers.length} customers to Firebase');
    } catch (e) {
      debugPrint('Error batch adding customers: $e');
      rethrow;
    }
  }

  /// Get customers updated after a certain date (for incremental sync)
  Future<List<Map<String, dynamic>>> getCustomersUpdatedAfter(DateTime date) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _customersRef
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
      debugPrint('Error getting customers updated after $date: $e');
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
