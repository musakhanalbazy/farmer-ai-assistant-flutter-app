import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// SERVICE
/// Centralised local user storage backed by SharedPreferences.
/// Keeps the signed-up account, the auth token, and the "remember me"
/// email/password so the Repository has one place to read/write from.
class UserStorageService {
  static const _usersKey = 'farmer_users_data';
  static const _authTokenKey = 'farmer_auth_token';

  Future<Map<String, dynamic>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw != null) return Map<String, dynamic>.from(jsonDecode(raw));
    return {'users': []};
  }

  Future<void> _save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final data = await _load();
    return List<Map<String, dynamic>>.from(data['users'] as List);
  }

  /// Adds a new user or updates the existing user record.
  Future<bool> addUser(Map<String, dynamic> newUser) async {
    final data = await _load();
    final users = List<Map<String, dynamic>>.from(data['users'] as List);

    final index = users.indexWhere(
      (u) => (u['emailOrPhone'] as String).toLowerCase().trim() ==
          (newUser['emailOrPhone'] as String).toLowerCase().trim(),
    );
    if (index >= 0) {
      users[index] = newUser;
    } else {
      users.add(newUser);
    }
    data['users'] = users;
    await _save(data);
    return true;
  }

  Future<Map<String, dynamic>?> findUser(String emailOrPhone) async {
    final users = await getUsers();
    for (final u in users) {
      if ((u['emailOrPhone'] as String).toLowerCase().trim() ==
          emailOrPhone.toLowerCase().trim()) {
        return u;
      }
    }
    return null;
  }

  Future<bool> validateLogin(String emailOrPhone, String password) async {
    final user = await findUser(emailOrPhone);
    return user != null && user['password'] == password;
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static const _activeUserKey = 'farmer_active_user';

  Future<void> saveActiveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeUserKey);
    if (raw != null) return Map<String, dynamic>.from(jsonDecode(raw));
    return null;
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_activeUserKey);
  }

  bool get isWeb => kIsWeb;
}
