import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_coding_questions_app/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? _user; // The Firebase User object
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Constructor: Listen to Auth Changes
  // ---------------------------------------------------------------------------
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Auto-redirects user when auth state changes
    });
  }

  // ---------------------------------------------------------------------------
  // 1. Sign Up (Email & Password)
  // ---------------------------------------------------------------------------
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);

    try {
      // Create user in Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Create user document in Firestore (for streaks)
      if (cred.user != null) {
        await _firestoreService.createUserIfNotExists(cred.user!.uid, email);
      }

      _setLoading(false);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false; // Failed
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Sign In
  // ---------------------------------------------------------------------------
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Sign Out
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper to update UI state
  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null; // Clear errors on new attempt
    notifyListeners();
  }
}
