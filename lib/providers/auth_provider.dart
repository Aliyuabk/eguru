import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      
      if (_token != null) {
        final userData = prefs.getString('user_data');
        if (userData != null) {
          try {
            final Map<String, dynamic> userMap = Map<String, dynamic>.from(
              await ApiService.getUser() ?? {}
            );
            if (userMap.isNotEmpty) {
              _user = User.fromJson(userMap);
              _isAuthenticated = true;
              print('✅ Auth restored for: ${_user?.email}');
              print('✅ Role: ${_user?.role}');
              return true;
            }
          } catch (e) {
            print('⚠️ Error restoring auth: $e');
          }
        }
      }
      
      _isAuthenticated = false;
      return false;
    } catch (e) {
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(Map<String, dynamic> userData, String token) async {
    print('📝 Setting user: ${userData['email']}');
    print('📝 Role level: ${userData['role_level']}');
    
    _user = User.fromJson(userData);
    _token = token;
    _isAuthenticated = true;
    
    print('👤 User set: ${_user?.email}');
    print('👤 Role: ${_user?.role}');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userData));
    
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _token = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    
    notifyListeners();
  }

  UserRole? getRoleEnum() {
    if (_user == null) return null;
    return _user?.role;
  }
}

// Add this for JSON encoding
String jsonEncode(Map<String, dynamic> data) {
  return data.toString();
}