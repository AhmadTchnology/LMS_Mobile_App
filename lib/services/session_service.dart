import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class SessionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _sessionKey = 'lms_auth_session';
  static const int _sessionDurationDays = 7;

  Future<void> saveSession(UserModel user) async {
    final session = {
      'user': {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'favorites': user.favorites,
        'completedLectures': user.completedLectures,
      },
      'expiresAt': DateTime.now()
          .add(const Duration(days: _sessionDurationDays))
          .millisecondsSinceEpoch,
      'lastActivity': DateTime.now().millisecondsSinceEpoch,
    };
    await _secureStorage.write(key: _sessionKey, value: jsonEncode(session));
  }

  Future<UserModel?> getCachedSession() async {
    final sessionStr = await _secureStorage.read(key: _sessionKey);
    if (sessionStr == null) return null;

    try {
      final session = jsonDecode(sessionStr) as Map<String, dynamic>;
      final expiresAt = session['expiresAt'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await _secureStorage.delete(key: _sessionKey);
        return null;
      }

      final userData = session['user'] as Map<String, dynamic>;
      return UserModel(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        role: userData['role'],
        favorites: List<String>.from(userData['favorites'] ?? []),
        completedLectures: List<String>.from(
          userData['completedLectures'] ?? [],
        ),
      );
    } catch (_) {
      await _secureStorage.delete(key: _sessionKey);
      return null;
    }
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _sessionKey);
  }
}
