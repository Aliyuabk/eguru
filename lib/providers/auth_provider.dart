// providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../services/fingerprint_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  String? _error;
  bool _fingerprintAvailable = false;
  bool _fingerprintEnabled = false;
  String? _savedUserEmail;
  String? _savedUserName;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get fingerprintAvailable => _fingerprintAvailable;
  bool get fingerprintEnabled => _fingerprintEnabled;
  String? get savedUserEmail => _savedUserEmail;
  String? get savedUserName => _savedUserName;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    _isInitialized = false;
    notifyListeners();

    try {
      // Check fingerprint availability and saved credentials
      _fingerprintAvailable = await FingerprintService.isFingerprintAvailable();
      _fingerprintEnabled = await FingerprintService.isFingerprintEnabled();
      _savedUserEmail = await FingerprintService.getSavedUserEmail();
      _savedUserName = await FingerprintService.getSavedUserName();
      
      // Check if user is already logged in
      final token = await _storage.read(key: 'auth_token');
      final userDataStr = await _storage.read(key: 'user_data');
      
      if (token != null && token.isNotEmpty && userDataStr != null) {
        try {
          // Verify token
          final isValid = await _apiService.verifyToken();
          if (isValid) {
            // Parse user data from string to Map
            try {
              final Map<String, dynamic> userMap = jsonDecode(userDataStr);
              _user = User.fromJson(userMap);
              _isAuthenticated = true;
            } catch (e) {
              print('🔴 Error parsing user data: $e');
              // If parsing fails, try to handle it as a Map directly
              try {
                final Map<String, dynamic> userMap = Map<String, dynamic>.from(userDataStr as Map);
                _user = User.fromJson(userMap);
                _isAuthenticated = true;
              } catch (e2) {
                print('🔴 Failed to parse user data: $e2');
                await _storage.delete(key: 'auth_token');
                await _storage.delete(key: 'user_data');
                _isAuthenticated = false;
              }
            }
          } else {
            // Token invalid, clear storage
            await _storage.delete(key: 'auth_token');
            await _storage.delete(key: 'user_data');
            _isAuthenticated = false;
          }
        } catch (e) {
          print('🔴 Token verification failed: $e');
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_data');
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      print('🔴 Initialization error: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response.success) {
        _user = response.user;
        _isAuthenticated = true;
        
        // Save user data and token
        if (_user != null) {
          final userJson = jsonEncode(_user!.toJson());
          await _storage.write(key: 'user_data', value: userJson);
        }
        if (response.token != null && response.token!.isNotEmpty) {
          await _storage.write(key: 'auth_token', value: response.token);
        }
        
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithFingerprint() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FingerprintService.loginWithFingerprint();
      
      if (result == null) {
        _error = 'Fingerprint authentication failed';
        return false;
      }
      
      // Get saved token and user data
      final token = await _storage.read(key: 'auth_token');
      final userDataStr = await _storage.read(key: 'user_data');
      
      if (token != null && token.isNotEmpty && userDataStr != null) {
        try {
          final isValid = await _apiService.verifyToken();
          if (isValid) {
            try {
              final Map<String, dynamic> userMap = jsonDecode(userDataStr);
              _user = User.fromJson(userMap);
              _isAuthenticated = true;
              return true;
            } catch (e) {
              print('🔴 Error parsing user data: $e');
            }
          }
        } catch (e) {
          print('🔴 Token verification failed: $e');
        }
      }
      
      // If token expired or not found, try to login with saved email
      final savedEmail = await FingerprintService.getSavedUserEmail();
      if (savedEmail != null) {
        // You might want to store password securely as well
        // For now, we'll return true but the user will need to re-enter password
        // after fingerprint verification
        return true;
      }
      
      _error = 'Fingerprint login failed';
      return false;
    } catch (e) {
      _error = 'Fingerprint login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      return await _apiService.forgotPassword(email);
    } catch (e) {
      return ForgotPasswordResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.changePassword(currentPassword, newPassword);
      if (!success) {
        _error = 'Failed to change password';
      }
      return success;
    } catch (e) {
      _error = 'Error changing password: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      print('🔴 Logout error: $e');
    } finally {
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
      notifyListeners();
    }
  }

  Future<bool> enableFingerprint(String email, String name) async {
    try {
      final success = await FingerprintService.enableFingerprint(
        email: email,
        name: name,
      );
      if (success) {
        await refreshFingerprintStatus();
      }
      return success;
    } catch (e) {
      print('🔴 Enable fingerprint error: $e');
      return false;
    }
  }

  Future<bool> disableFingerprint() async {
    try {
      final success = await FingerprintService.disableFingerprint();
      if (success) {
        await refreshFingerprintStatus();
      }
      return success;
    } catch (e) {
      print('🔴 Disable fingerprint error: $e');
      return false;
    }
  }

  Future<void> refreshFingerprintStatus() async {
    _fingerprintEnabled = await FingerprintService.isFingerprintEnabled();
    _savedUserEmail = await FingerprintService.getSavedUserEmail();
    _savedUserName = await FingerprintService.getSavedUserName();
    notifyListeners();
  }

  // Helper method to get user's full name
  String get userFullName => _user?.fullName ?? _user?.displayName ?? 'User';
  
  // Helper method to get user's role
  String get userRole => _user?.roleDisplayName ?? 'Unknown Role';
  
  // Helper method to check if user has a specific role
  bool hasRole(String role) {
    return _user?.roleLevel == role;
  }
  
  // Helper method to check if user is a coordinator
  bool get isCoordinator => _user?.isCoordinator ?? false;
  
  // Helper method to check if user is an agent
  bool get isAgent => _user?.isPuAgent ?? false;
}