import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/firebase_auth_service.dart';

/// Remote datasource for Medicine operations using Firebase Firestore
/// 
/// This datasource handles all Firebase operations for medicines.
/// It's designed to work gracefully when Firebase is not available.
class MedicineRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseAuthService _authService;
  
  bool _isInitialized = false;

  MedicineRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseAuthService? authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _authService = authService ?? FirebaseAuthService();

  /// Get Firestore collection reference for current user
  CollectionReference<Map<String, dynamic>> get _medicinesRef {
    final userId = _auth.currentUser?.uid ?? 'default';
    return _firestore.collection('users').doc(userId).collection('medicines');
  }

  /// Check if Firebase is available
  bool get isAvailable => _isInitialized;

  /// Initialize the remote datasource
  Future<void> init() async {
    try {
      await _firestore.enableNetwork();
      
      // Ensure admin authentication
      final authenticated = await _authService.ensureAuthenticated();
      if (!authenticated) {
        debugPrint('Firebase: Failed to authenticate admin');
        _isInitialized = false;
        return;
      }
      
      _isInitialized = true;
      debugPrint('MedicineRemoteDatasource initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase not available for medicines: $e');
    }
  }

  /// Add medicine to Firebase
  Future<String?> addMedicine(Map<String, dynamic> medicineJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping addMedicine');
      return null;
    }
    
    try {
      final docRef = _medicinesRef.doc(medicineJson['id']);
      await docRef.set({
        ...medicineJson,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Medicine added to Firebase: ${medicineJson['id']}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding medicine to Firebase: $e');
      rethrow;
    }
  }

  /// Update medicine in Firebase
  Future<void> updateMedicine(Map<String, dynamic> medicineJson) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping updateMedicine');
      return;
    }
    
    try {
      final docRef = _medicinesRef.doc(medicineJson['id']);
      
      final doc = await docRef.get();
      if (!doc.exists) {
        await addMedicine(medicineJson);
        return;
      }
      
      await docRef.update({
        ...medicineJson,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Medicine updated in Firebase: ${medicineJson['id']}');
    } catch (e) {
      debugPrint('Error updating medicine in Firebase: $e');
      rethrow;
    }
  }

  /// Delete medicine from Firebase
  Future<void> deleteMedicine(String id) async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - skipping deleteMedicine');
      return;
    }
    
    try {
      await _medicinesRef.doc(id).delete();
      debugPrint('Medicine deleted from Firebase: $id');
    } catch (e) {
      debugPrint('Error deleting medicine from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch all medicines from Firebase
  Future<List<Map<String, dynamic>>> fetchMedicines() async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized - returning empty list');
      return [];
    }
    
    try {
      final snapshot = await _medicinesRef
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
          'mfgDate': _timestampToIso(data['mfgDate']),
          'expiryDate': _timestampToIso(data['expiryDate']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching medicines from Firebase: $e');
      return [];
    }
  }

  /// Get single medicine by ID from Firebase
  Future<Map<String, dynamic>?> getMedicineById(String id) async {
    if (!_isInitialized) return null;
    
    try {
      final doc = await _medicinesRef.doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return {
        ...data,
        'id': doc.id,
        'firebaseId': doc.id,
        'createdAt': _timestampToIso(data['createdAt']),
        'updatedAt': _timestampToIso(data['updatedAt']),
        'mfgDate': _timestampToIso(data['mfgDate']),
        'expiryDate': _timestampToIso(data['expiryDate']),
      };
    } catch (e) {
      debugPrint('Error getting medicine by ID from Firebase: $e');
      return null;
    }
  }

  /// Watch medicines stream from Firebase (real-time updates)
  Stream<List<Map<String, dynamic>>> watchMedicines() {
    if (!_isInitialized) return Stream.value([]);
    
    return _medicinesRef
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
          'mfgDate': _timestampToIso(data['mfgDate']),
          'expiryDate': _timestampToIso(data['expiryDate']),
        };
      }).toList();
    });
  }

  /// Batch add multiple medicines
  Future<void> batchAddMedicines(List<Map<String, dynamic>> medicines) async {
    if (!_isInitialized || medicines.isEmpty) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final medicine in medicines) {
        final docRef = _medicinesRef.doc(medicine['id']);
        batch.set(docRef, {
          ...medicine,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Batch added ${medicines.length} medicines to Firebase');
    } catch (e) {
      debugPrint('Error batch adding medicines: $e');
      rethrow;
    }
  }

  /// Get medicines updated after a certain date (for incremental sync)
  Future<List<Map<String, dynamic>>> getMedicinesUpdatedAfter(DateTime date) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _medicinesRef
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
          'mfgDate': _timestampToIso(data['mfgDate']),
          'expiryDate': _timestampToIso(data['expiryDate']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting medicines updated after $date: $e');
      return [];
    }
  }

  /// Get medicines by category
  Future<List<Map<String, dynamic>>> getMedicinesByCategory(String category) async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _medicinesRef
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
          'mfgDate': _timestampToIso(data['mfgDate']),
          'expiryDate': _timestampToIso(data['expiryDate']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting medicines by category: $e');
      return [];
    }
  }

  /// Get expiring medicines (within given days)
  Future<List<Map<String, dynamic>>> getExpiringMedicines({int days = 30}) async {
    if (!_isInitialized) return [];
    
    try {
      final now = DateTime.now();
      final threshold = now.add(Duration(days: days));
      
      final snapshot = await _medicinesRef
          .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(threshold))
          .where('expiryDate', isGreaterThan: Timestamp.fromDate(now))
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'firebaseId': doc.id,
          'createdAt': _timestampToIso(data['createdAt']),
          'updatedAt': _timestampToIso(data['updatedAt']),
          'mfgDate': _timestampToIso(data['mfgDate']),
          'expiryDate': _timestampToIso(data['expiryDate']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting expiring medicines: $e');
      return [];
    }
  }

  /// Get low stock medicines
  Future<List<Map<String, dynamic>>> getLowStockMedicines() async {
    if (!_isInitialized) return [];
    
    try {
      final snapshot = await _medicinesRef.get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id,
              'firebaseId': doc.id,
              'createdAt': _timestampToIso(data['createdAt']),
              'updatedAt': _timestampToIso(data['updatedAt']),
              'mfgDate': _timestampToIso(data['mfgDate']),
              'expiryDate': _timestampToIso(data['expiryDate']),
            };
          })
          .where((m) => (m['quantity'] as int) <= (m['minStockLevel'] as int))
          .toList();
    } catch (e) {
      debugPrint('Error getting low stock medicines: $e');
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
