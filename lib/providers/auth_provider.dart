import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Check for cached session first (offline-first)
    _user = await _authService.getCachedSession();

    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((firebaseUser) async {
      _isLoading = true;
      if (firebaseUser != null) {
        _user = await _authService.getUserById(firebaseUser.uid);
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAdminManagedUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.createAdminManagedUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void updateUserProfile(UserModel updatedUser) {
    _user = updatedUser;
    _authService.updateCachedUser(updatedUser);
    notifyListeners();
  }
}
