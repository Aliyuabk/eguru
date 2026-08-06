import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../services/fingerprint_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // ============================================================
  // STATE
  // ============================================================
  
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  String? _error;
  
  bool _fingerprintAvailable = false;
  bool _fingerprintEnabled = false;
  String? _savedUserEmail;
  String? _savedUserName;

  // ============================================================
  // GETTERS
  // ============================================================
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  
  bool get fingerprintAvailable => _fingerprintAvailable;
  bool get fingerprintEnabled => _fingerprintEnabled;
  String? get savedUserEmail => _savedUserEmail;
  String? get savedUserName => _savedUserName;
  
  bool get isMobileRole => _user?.isMobileRole ?? false;
  String get redirectUrl => _user?.redirectUrl ?? 'https://eguruelection.kowagurutech.ng';

  // ============================================================
  // STORAGE KEYS
  // ============================================================
  
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyUserEmail = 'saved_user_email';
  static const String _keyUserName = 'saved_user_name';

  // ============================================================
  // INITIALIZATION
  // ============================================================
  
  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    _isInitialized = false;
    notifyListeners();

    try {
      print('🟡 Initializing AuthProvider...');
      await _initializeFingerprintStatus();
      await _restoreUserSession();
      print('🟢 AuthProvider initialization complete');
    } catch (e) {
      print('🔴 Initialization error: $e');
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ============================================================
  // FINGERPRINT
  // ============================================================
  
  Future<void> _initializeFingerprintStatus() async {
    try {
      _fingerprintAvailable = await FingerprintService.isFingerprintAvailable();
      _fingerprintEnabled = await FingerprintService.isFingerprintEnabled();
      _savedUserEmail = await FingerprintService.getSavedUserEmail();
      _savedUserName = await FingerprintService.getSavedUserName();
      print('🟢 Fingerprint Status: Available=$_fingerprintAvailable, Enabled=$_fingerprintEnabled');
    } catch (e) {
      print('🔴 Fingerprint status error: $e');
    }
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================
  
  Future<void> _restoreUserSession() async {
    try {
      final token = await _storage.read(key: _keyAuthToken);
      final userDataStr = await _storage.read(key: _keyUserData);

      print('🟡 Restoring session: token=${token != null}, userData=${userDataStr != null}');

      if (token == null || token.isEmpty || userDataStr == null) {
        print('🟡 No session found');
        _isAuthenticated = false;
        _user = null;
        return;
      }

      // Parse user data from stored JSON string
      final user = await _parseUserData(userDataStr);
      if (user == null) {
        print('🔴 Failed to parse user data');
        await _clearSession();
        return;
      }

      // Verify token is still valid
      final isValid = await _apiService.verifyToken();
      print('🟢 Token valid: $isValid');

      if (isValid) {
        _user = user;
        _isAuthenticated = true;
        print('🟢 Session restored: ${_user?.displayName} (${_user?.roleLevel})');

        // Check if user has a mobile role
        if (!isMobileRole) {
          print('🔴 User is not a mobile role. Clearing session.');
          _isAuthenticated = false;
          _user = null;
          await _clearSession();
        }
      } else {
        print('🟡 Token invalid. Clearing session.');
        await _clearSession();
      }
    } catch (e) {
      print('🔴 Error restoring session: $e');
      await _clearSession();
    }
  }

  /// Parse user data from stored JSON string with proper error handling
  Future<User?> _parseUserData(String userDataStr) async {
    try {
      print('🟡 Parsing user data from storage...');
      
      // Clean the string if needed
      String cleanData = userDataStr.trim();
      
      // Try to parse as JSON
      final Map<String, dynamic> userMap = jsonDecode(cleanData);
      
      // Check if it's a valid map
      if (userMap.isEmpty) {
        print('🔴 Parsed user data is empty');
        return null;
      }

      // Create User object
      final user = User.fromJson(userMap);
      print('🟢 Successfully parsed user: ${user.displayName}');
      return user;
    } catch (e) {
      print('🔴 Error parsing user data: $e');
      print('🔴 Data: ${userDataStr.substring(0, userDataStr.length > 100 ? 100 : userDataStr.length)}...');
      return null;
    }
  }

  Future<void> _saveSession(LoginResponse response) async {
    try {
      if (_user != null) {
        final userJson = jsonEncode(_user!.toJson());
        await _storage.write(key: _keyUserData, value: userJson);
        print('🟢 User data saved to storage');
      }
      
      if (response.token != null && response.token!.isNotEmpty) {
        await _storage.write(key: _keyAuthToken, value: response.token);
        print('🟢 Token saved to storage');
      }
    } catch (e) {
      print('🔴 Error saving session: $e');
      rethrow;
    }
  }

  Future<void> _clearSession() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyUserData);
      _user = null;
      _isAuthenticated = false;
      print('🟢 Session cleared');
    } catch (e) {
      print('🔴 Error clearing session: $e');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🟡 ====== PROVIDER LOGIN ======');
      print('🟡 Email: $email');

      final response = await _apiService.login(email, password);
      print('🟡 Response success: ${response.success}');

      if (!response.success) {
        _error = response.message ?? 'Login failed';
        print('🔴 Login failed: $_error');
        return false;
      }

      if (response.user == null) {
        _error = 'User data not found in response';
        print('🔴 $_error');
        return false;
      }

      _user = response.user;
      _isAuthenticated = true;

      print('🟢 User logged in: ${_user?.displayName}');
      print('🟢 Role: ${_user?.roleLevel}');
      print('🟢 Is Mobile Role: ${_user?.isMobileRole}');

      // Check if user has a mobile role
      if (!_user!.isMobileRole) {
        print('🔴 User is not a mobile role. Redirecting to web.');
        _isAuthenticated = false;
        _error = 'This account does not have mobile access. Please use the web dashboard.';
        await _clearSession();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _saveSession(response);
      print('🟢 Session saved successfully');
      return true;

    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      print('🔴 ❌ Login error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FINGERPRINT LOGIN
  // ============================================================
  
  Future<bool> loginWithFingerprint() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🟡 Fingerprint login attempt');
      final result = await FingerprintService.loginWithFingerprint();

      if (result == null) {
        _error = 'Fingerprint authentication failed';
        print('🔴 $error');
        return false;
      }

      final token = await _storage.read(key: _keyAuthToken);
      final userDataStr = await _storage.read(key: _keyUserData);

      if (token == null || token.isEmpty || userDataStr == null) {
        _error = 'No saved session found';
        print('🔴 $_error');
        return false;
      }

      // Verify token is still valid
      final isValid = await _apiService.verifyToken();
      if (!isValid) {
        _error = 'Session expired. Please login with password.';
        print('🔴 $_error');
        await _clearSession();
        return false;
      }

      // Parse user data
      final user = await _parseUserData(userDataStr);
      if (user == null) {
        _error = 'Invalid user data. Please login with password.';
        print('🔴 $_error');
        await _clearSession();
        return false;
      }

      // Check if user has a mobile role
      if (!user.isMobileRole) {
        _isAuthenticated = false;
        _error = 'This account does not have mobile access.';
        await _clearSession();
        return false;
      }

      _user = user;
      _isAuthenticated = true;
      print('🟢 Fingerprint login successful: ${_user?.displayName}');
      return true;

    } catch (e) {
      _error = 'Fingerprint login failed: ${e.toString()}';
      print('🔴 $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🟡 Logging out...');
      await _apiService.logout();
      await _clearSession();
      print('🟢 Logout successful');
    } catch (e) {
      print('🔴 Logout error: $e');
      await _clearSession();
    } finally {
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // PASSWORD OPERATIONS
  // ============================================================
  
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      print('🟡 Forgot password for: $email');
      final response = await _apiService.forgotPassword(email);
      print('🟢 Response: ${response.success}');
      return response;
    } catch (e) {
      print('🔴 Forgot password error: $e');
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
      print('🟡 Changing password');
      final success = await _apiService.changePassword(currentPassword, newPassword);
      if (!success) {
        _error = 'Failed to change password';
        print('🔴 $_error');
      } else {
        print('🟢 Password changed successfully');
      }
      return success;
    } catch (e) {
      _error = 'Error changing password: ${e.toString()}';
      print('🔴 $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FINGERPRINT SETTINGS
  // ============================================================
  
  Future<bool> enableFingerprint(String email, String name) async {
    try {
      print('🟡 Enabling fingerprint for: $email');
      final success = await FingerprintService.enableFingerprint(
        email: email,
        name: name,
      );
      if (success) {
        await refreshFingerprintStatus();
        print('🟢 Fingerprint enabled');
      }
      return success;
    } catch (e) {
      print('🔴 Enable fingerprint error: $e');
      return false;
    }
  }

  Future<bool> disableFingerprint() async {
    try {
      print('🟡 Disabling fingerprint');
      final success = await FingerprintService.disableFingerprint();
      if (success) {
        await refreshFingerprintStatus();
        print('🟢 Fingerprint disabled');
      }
      return success;
    } catch (e) {
      print('🔴 Disable fingerprint error: $e');
      return false;
    }
  }

  Future<void> refreshFingerprintStatus() async {
    try {
      _fingerprintEnabled = await FingerprintService.isFingerprintEnabled();
      _savedUserEmail = await FingerprintService.getSavedUserEmail();
      _savedUserName = await FingerprintService.getSavedUserName();
      notifyListeners();
    } catch (e) {
      print('🔴 Refresh fingerprint status error: $e');
    }
  }

  bool shouldShowFingerprintLogin() {
    return _fingerprintAvailable && 
           _fingerprintEnabled && 
           _savedUserName != null &&
           _savedUserEmail != null;
  }

  // ============================================================
  // UTILITY
  // ============================================================
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Force a refresh of the user data from the server
  Future<bool> refreshUserData() async {
    try {
      final token = await _storage.read(key: _keyAuthToken);
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await _apiService.getProfile();
      if (response != null && response['success'] == true) {
        final userData = response['user'];
        if (userData != null) {
          _user = User.fromJson(userData);
          // Update stored user data
          final userJson = jsonEncode(_user!.toJson());
          await _storage.write(key: _keyUserData, value: userJson);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('🔴 Error refreshing user data: $e');
      return false;
    }
  }
}