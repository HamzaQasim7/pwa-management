import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firebase Authentication Service
/// 
/// Handles authentication for the admin account (admin@aftab.com)
/// All data is stored under this single admin account
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Admin credentials
  static const String _adminEmail = 'admin@aftab.com';
  static const String _adminPassword = 'Admin@007'; 
  
  bool _isInitialized = false;
  bool _isSigningIn = false;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Initialize authentication - signs in with admin account
  /// This should be called once at app startup
  Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('FirebaseAuthService: Already initialized');
      return isAuthenticated;
    }

    if (_isSigningIn) {
      debugPrint('FirebaseAuthService: Sign-in already in progress');
      return false;
    }

    try {
      _isSigningIn = true;
      
      // Check if already signed in with the admin account
      if (_auth.currentUser != null) {
        if (_auth.currentUser!.email == _adminEmail) {
          _isInitialized = true;
          debugPrint('FirebaseAuthService: Already signed in as admin');
          return true;
        } else {
          // Sign out if signed in with different account
          await _auth.signOut();
          debugPrint('FirebaseAuthService: Signed out from different account');
        }
      }

      // Try to sign in with email/password
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: _adminEmail,
          password: _adminPassword,
        );
        
        if (credential.user != null) {
          _isInitialized = true;
          debugPrint('FirebaseAuthService: Successfully signed in as admin');
          return true;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // User doesn't exist, create it
          debugPrint('FirebaseAuthService: Admin user not found, creating...');
          try {
            final credential = await _auth.createUserWithEmailAndPassword(
              email: _adminEmail,
              password: _adminPassword,
            );
            
            if (credential.user != null) {
              _isInitialized = true;
              debugPrint('FirebaseAuthService: Admin user created and signed in');
              return true;
            }
          } catch (createError) {
            debugPrint('FirebaseAuthService: Error creating admin user: $createError');
            return false;
          }
        } else if (e.code == 'wrong-password') {
          debugPrint('FirebaseAuthService: Wrong password for admin account');
          return false;
        } else {
          debugPrint('FirebaseAuthService: Auth error: ${e.code} - ${e.message}');
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('FirebaseAuthService: Error initializing: $e');
      return false;
    } finally {
      _isSigningIn = false;
    }
  }

  /// Ensure user is authenticated (re-authenticate if needed)
  Future<bool> ensureAuthenticated() async {
    if (!_isInitialized) {
      return await initialize();
    }

    if (isAuthenticated && _auth.currentUser!.email == _adminEmail) {
      return true;
    }

    // Re-authenticate
    _isInitialized = false;
    return await initialize();
  }

  /// Sign out (not typically used, but available if needed)
  Future<void> signOut() async {
    await _auth.signOut();
    _isInitialized = false;
    debugPrint('FirebaseAuthService: Signed out');
  }
}

