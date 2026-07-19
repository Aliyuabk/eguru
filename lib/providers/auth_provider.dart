import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    _isInitialized = false;
    notifyListeners();
    
    try {
      _user = await _authService.getUser();
      final token = await _authService.getToken();
      
      if (_user != null && token != null && token.isNotEmpty) {
        // Verify token is still valid
        final isValid = await _apiService.verifyToken();
        if (!isValid) {
          _user = null;
          await _authService.clearAuthData();
        }
      } else {
        _user = null;
      }
    } catch (e) {
      print('Auth check error: $e');
      _user = null;
      await _authService.clearAuthData();
    }
    
    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response.success && response.user != null) {
        _user = response.user;
        await _authService.saveAuthData(_user!, response.token ?? '');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      // Call logout API
      await _apiService.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear user data
      _user = null;
      await _authService.clearAuthData();
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
      print('User logged out successfully');
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _apiService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Check auth status method (public)
  Future<void> checkAuthStatus() async {
    await _checkAuthStatus();
  }
}