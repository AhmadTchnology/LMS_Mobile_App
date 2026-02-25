import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/auth_status.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final FirestoreService _firestoreService = FirestoreService();
  
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  bool _isAuthenticating = false;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _status == AuthStatus.initial || _isAuthenticating;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Try to load cached session for instant offline-ready UI
    final cachedUser = await _sessionService.getCachedSession();
    if (cachedUser != null) {
      _user = cachedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
    }

    // 2. Listen to Firebase Auth state changes
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      _userSubscription?.cancel();

      if (firebaseUser != null) {
        // User logged in on Firebase. Fetch their full profile.
        try {
          UserModel? freshUser = await _authService.getUserById(firebaseUser.uid);
          if (freshUser == null && firebaseUser.email != null) {
            freshUser = await _authService.getUserByEmail(firebaseUser.email!);
          }

          if (freshUser != null) {
            _user = freshUser;
            _status = AuthStatus.authenticated;
            await _sessionService.saveSession(freshUser);
            _subscribeToUserStream(freshUser.id);
            notifyListeners();
          } else {
             // User in Firebase but not in Firestore (e.g. signup in progress)
             // We don't mark as unauthenticated here to avoid interrupting signups.
             // If they were cached, we leave it be until signup completes.
             if (_status == AuthStatus.initial) {
                 _status = AuthStatus.unauthenticated;
                 notifyListeners();
             }
          }
        } catch (e) {
          debugPrint('Error fetching user profile: $e');
          // If network error but we have cache, keep showing cached user.
          if (_user == null) {
             _status = AuthStatus.unauthenticated;
             notifyListeners();
          }
        }
      } else {
        // Explicitly signed out from Firebase
        _user = null;
        _status = AuthStatus.unauthenticated;
        await _sessionService.clearSession();
        notifyListeners();
      }
    });
  }

  void _subscribeToUserStream(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestoreService.userStream(uid).listen((updatedUser) {
      if (updatedUser != null) {
        _user = updatedUser;
        _sessionService.saveSession(updatedUser);
        notifyListeners();
      }
    });
  }

  Future<void> login(String email, String password) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
      // The stream listener will handle updating _user and _status
    } catch (e) {
      _isAuthenticating = false;
      notifyListeners();
      rethrow;
    } finally {
      // Small delay in resetting flag to allow stream to catch up
      Future.delayed(const Duration(milliseconds: 500), () {
        _isAuthenticating = false;
        notifyListeners();
      });
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      await _authService.signUp(name: name, email: email, password: password);
      // The stream listener will handle updating
    } catch (e) {
       _isAuthenticating = false;
       notifyListeners();
       rethrow;
    } finally {
       Future.delayed(const Duration(milliseconds: 500), () {
        _isAuthenticating = false;
        notifyListeners();
      });
    }
  }

  Future<void> createAdminManagedUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      await _authService.createAdminManagedUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    // The stream listener will set _user to null and clear session
  }

  void updateUserProfile(UserModel updatedUser) {
    _user = updatedUser;
    _sessionService.saveSession(updatedUser);
    notifyListeners();
  }

  Future<void> toggleFavorite(String lectureId, bool isFavorite) async {
    if (_user == null) return;
    
    final originalUser = _user!;
    final newFavorites = List<String>.from(_user!.favorites);
    if (isFavorite) {
      if (!newFavorites.contains(lectureId)) newFavorites.add(lectureId);
    } else {
      newFavorites.remove(lectureId);
    }
    
    _user = _user!.copyWith(favorites: newFavorites);
    notifyListeners();
    
    try {
      await _firestoreService.toggleFavorite(originalUser.id, lectureId, isFavorite);
    } catch (e) {
      _user = originalUser;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleCompletion(String lectureId, bool isCompleted) async {
    if (_user == null) return;
    
    final originalUser = _user!;
    final newCompletions = List<String>.from(_user!.completedLectures);
    if (isCompleted) {
      if (!newCompletions.contains(lectureId)) newCompletions.add(lectureId);
    } else {
      newCompletions.remove(lectureId);
    }
    
    _user = _user!.copyWith(completedLectures: newCompletions);
    notifyListeners();

    try {
      await _firestoreService.toggleCompletion(originalUser.id, lectureId, isCompleted);
    } catch (e) {
      _user = originalUser;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
