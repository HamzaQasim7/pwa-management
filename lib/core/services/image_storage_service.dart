import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'firebase_auth_service.dart';

/// Service for uploading and managing images in Firebase Storage
/// 
/// Handles image upload, download, and deletion for all entities
/// in the VetCare application.
class ImageStorageService {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final FirebaseAuthService _authService;
  
  bool _isInitialized = false;

  ImageStorageService({
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    FirebaseAuthService? authService,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _authService = authService ?? FirebaseAuthService();

  /// Check if Firebase Storage is available
  bool get isAvailable => _isInitialized;

  /// Get the storage reference for the current user
  Reference get _userStorageRef {
    final userId = _auth.currentUser?.uid ?? 'default';
    return _storage.ref().child('users').child(userId);
  }

  /// Initialize the image storage service
  Future<void> init() async {
    try {
      // Ensure admin authentication
      final authenticated = await _authService.ensureAuthenticated();
      if (!authenticated) {
        debugPrint('Firebase Storage: Failed to authenticate admin');
        _isInitialized = false;
        return;
      }
      
      _isInitialized = true;
      debugPrint('ImageStorageService initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase Storage not available: $e');
    }
  }

  /// Upload an image file to Firebase Storage
  /// 
  /// [imageFile] - The local image file to upload
  /// [entityType] - Type of entity (customer, feedProduct, medicine, etc.)
  /// [entityId] - The unique ID of the entity
  /// 
  /// Returns the download URL of the uploaded image
  Future<String?> uploadImage(
    File imageFile,
    String entityType,
    String entityId,
  ) async {
    if (!_isInitialized) {
      debugPrint('Firebase Storage not initialized - skipping upload');
      return null;
    }
    
    try {
      // Create a unique filename
      final extension = path.extension(imageFile.path).toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${entityType}_${entityId}_$timestamp$extension';
      
      // Get the storage reference
      final ref = _userStorageRef
          .child('images')
          .child(entityType)
          .child(fileName);
      
      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'entityType': entityType,
          'entityId': entityId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      final uploadTask = ref.putFile(imageFile, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image from bytes (for web platform)
  Future<String?> uploadImageFromBytes(
    Uint8List imageBytes,
    String entityType,
    String entityId, {
    String extension = '.jpg',
  }) async {
    if (!_isInitialized) {
      debugPrint('Firebase Storage not initialized - skipping upload');
      return null;
    }
    
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${entityType}_${entityId}_$timestamp$extension';
      
      final ref = _userStorageRef
          .child('images')
          .child(entityType)
          .child(fileName);
      
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'entityType': entityType,
          'entityId': entityId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Image uploaded from bytes successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image from bytes: $e');
      return null;
    }
  }

  /// Delete an image from Firebase Storage by URL
  Future<bool> deleteImage(String imageUrl) async {
    if (!_isInitialized) {
      debugPrint('Firebase Storage not initialized - skipping delete');
      return false;
    }
    
    // Skip if it's not a Firebase Storage URL
    if (!imageUrl.contains('firebase') && !imageUrl.contains('googleapis')) {
      debugPrint('Not a Firebase Storage URL - skipping delete');
      return false;
    }
    
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Delete all images for an entity
  Future<void> deleteEntityImages(String entityType, String entityId) async {
    if (!_isInitialized) return;
    
    try {
      final ref = _userStorageRef.child('images').child(entityType);
      final listResult = await ref.listAll();
      
      // Find and delete images matching the entity ID
      for (final item in listResult.items) {
        if (item.name.contains(entityId)) {
          await item.delete();
          debugPrint('Deleted image: ${item.name}');
        }
      }
    } catch (e) {
      debugPrint('Error deleting entity images: $e');
    }
  }

  /// Get all images for an entity
  Future<List<String>> getEntityImages(String entityType, String entityId) async {
    if (!_isInitialized) return [];
    
    try {
      final ref = _userStorageRef.child('images').child(entityType);
      final listResult = await ref.listAll();
      
      final urls = <String>[];
      for (final item in listResult.items) {
        if (item.name.contains(entityId)) {
          final url = await item.getDownloadURL();
          urls.add(url);
        }
      }
      
      return urls;
    } catch (e) {
      debugPrint('Error getting entity images: $e');
      return [];
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String entityType,
    String entityId,
  ) async {
    final urls = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final uniqueId = '${entityId}_$i';
      final url = await uploadImage(imageFiles[i], entityType, uniqueId);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Get storage usage for current user
  Future<int> getStorageUsage() async {
    if (!_isInitialized) return 0;
    
    try {
      int totalBytes = 0;
      
      final listResult = await _userStorageRef.child('images').listAll();
      
      for (final prefix in listResult.prefixes) {
        final subListResult = await prefix.listAll();
        for (final item in subListResult.items) {
          final metadata = await item.getMetadata();
          totalBytes += metadata.size ?? 0;
        }
      }
      
      return totalBytes;
    } catch (e) {
      debugPrint('Error getting storage usage: $e');
      return 0;
    }
  }

  /// Clear all images for current user (use with caution)
  Future<void> clearAllImages() async {
    if (!_isInitialized) return;
    
    try {
      final ref = _userStorageRef.child('images');
      final listResult = await ref.listAll();
      
      for (final prefix in listResult.prefixes) {
        final subListResult = await prefix.listAll();
        for (final item in subListResult.items) {
          await item.delete();
        }
      }
      
      debugPrint('All images cleared');
    } catch (e) {
      debugPrint('Error clearing all images: $e');
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  /// Compress and upload image (for large files)
  /// Note: Actual compression would require image processing package
  Future<String?> uploadImageCompressed(
    File imageFile,
    String entityType,
    String entityId, {
    int maxWidth = 1024,
    int quality = 85,
  }) async {
    // For now, just upload the original file
    // In production, you would use image compression package
    return uploadImage(imageFile, entityType, entityId);
  }

  /// Check if a URL is a valid Firebase Storage URL
  bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
           url.contains('storage.googleapis.com');
  }

  /// Generate a temporary download URL (with expiration)
  Future<String?> getTemporaryDownloadUrl(
    String storagePath, {
    Duration expiration = const Duration(hours: 1),
  }) async {
    if (!_isInitialized) return null;
    
    try {
      final ref = _storage.ref().child(storagePath);
      // Firebase Storage URLs don't expire by default, 
      // but you can use signed URLs with expiration
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting temporary download URL: $e');
      return null;
    }
  }
}
