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
  
  // ============================================================
  // PRIVATE STATE
  // ============================================================
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  String? _error;
  
  // Fingerprint state
  bool _fingerprintAvailable = false;
  bool _fingerprintEnabled = false;
  String? _savedUserEmail;
  String? _savedUserName;

  // ============================================================
  // PUBLIC GETTERS
  // ============================================================
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  
  // Fingerprint getters
  bool get fingerprintAvailable => _fingerprintAvailable;
  bool get fingerprintEnabled => _fingerprintEnabled;
  String? get savedUserEmail => _savedUserEmail;
  String? get savedUserName => _savedUserName;
  
  // User helper getters
  String get userFullName => _user?.fullName ?? _user?.displayName ?? 'User';
  String get userRole => _user?.roleDisplayName ?? 'Unknown Role';
  String get userEmail => _user?.email ?? _savedUserEmail ?? '';
  bool get isCoordinator => _user?.isCoordinator ?? false;
  bool get isAgent => _user?.isPuAgent ?? false;
  
  bool hasRole(String role) => _user?.roleLevel == role;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  AuthProvider() {
    _initialize();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================
  Future<void> _initialize() async {
    _isLoading = true;
    _isInitialized = false;
    notifyListeners();

    try {
      // Check fingerprint availability and saved credentials
      await _initializeFingerprintStatus();
      
      // Check if user is already logged in
      await _restoreUserSession();
      
    } catch (e) {
      print('🔴 Initialization error: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _initializeFingerprintStatus() async {
    try {
      _fingerprintAvailable = await FingerprintService.isFingerprintAvailable();
      _fingerprintEnabled = await FingerprintService.isFingerprintEnabled();
      _savedUserEmail = await FingerprintService.getSavedUserEmail();
      _savedUserName = await FingerprintService.getSavedUserName();
      
      print('🟢 Fingerprint Status:');
      print('   Available: $_fingerprintAvailable');
      print('   Enabled: $_fingerprintEnabled');
      print('   Saved Email: $_savedUserEmail');
      print('   Saved Name: $_savedUserName');
    } catch (e) {
      print('🔴 Error checking fingerprint status: $e');
    }
  }

  Future<void> _restoreUserSession() async {
    final token = await _storage.read(key: 'auth_token');
    final userDataStr = await _storage.read(key: 'user_data');
    
    if (token == null || token.isEmpty || userDataStr == null) {
      _isAuthenticated = false;
      return;
    }

    try {
      // Verify token with server
      final isValid = await _apiService.verifyToken();
      
      if (isValid) {
        _user = await _parseUserData(userDataStr);
        _isAuthenticated = true;
        print('🟢 User session restored successfully');
      } else {
        print('🟡 Token invalid, clearing session');
        await _clearSession();
      }
    } catch (e) {
      print('🔴 Error restoring session: $e');
      await _clearSession();
    }
  }

  Future<User?> _parseUserData(String userDataStr) async {
    try {
      final Map<String, dynamic> userMap = jsonDecode(userDataStr);
      return User.fromJson(userMap);
    } catch (e) {
      print('🔴 Error parsing user data: $e');
      return null;
    }
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    _user = null;
    _isAuthenticated = false;
  }

  // ============================================================
  // AUTHENTICATION METHODS
  // ============================================================

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🟡 Attempting login for: $email');
      
      final response = await _apiService.login(email, password);
      
      if (response.success && response.user != null) {
        _user = response.user;
        _isAuthenticated = true;
        
        // Save session
        await _saveSession(response);
        
        print('🟢 Login successful for: ${_user?.displayName}');
        return true;
      } else {
        _error = response.message ?? 'Login failed';
        print('🔴 Login failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      print('🔴 Login error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession(dynamic response) async {
    if (_user != null) {
      final userJson = jsonEncode(_user!.toJson());
      await _storage.write(key: 'user_data', value: userJson);
    }
    if (response.token != null && response.token!.isNotEmpty) {
      await _storage.write(key: 'auth_token', value: response.token);
    }
  }

  Future<bool> loginWithFingerprint() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🟡 Attempting fingerprint login...');
      
      // Authenticate with fingerprint
      final result = await FingerprintService.loginWithFingerprint();
      
      if (result == null) {
        _error = 'Fingerprint authentication failed';
        print('🔴 $_error');
        return false;
      }
      
      // Try to restore session
      final token = await _storage.read(key: 'auth_token');
      final userDataStr = await _storage.read(key: 'user_data');
      
      if (token != null && token.isNotEmpty && userDataStr != null) {
        final isValid = await _apiService.verifyToken();
        if (isValid) {
          _user = await _parseUserData(userDataStr);
          if (_user != null) {
            _isAuthenticated = true;
            print('🟢 Fingerprint login successful for: ${_user?.displayName}');
            return true;
          }
        }
      }
      
      // If session not valid, but fingerprint was verified
      // The user will need to re-enter password
      print('🟡 Fingerprint verified but session expired. Please login with password.');
      _error = 'Session expired. Please login with password.';
      return false;
      
    } catch (e) {
      _error = 'Fingerprint login failed: ${e.toString()}';
      print('🔴 $_error');
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
      print('🟡 Logging out...');
      await _apiService.logout();
      await _clearSession();
      print('🟢 Logout successful');
    } catch (e) {
      print('🔴 Logout error: $e');
      // Still clear local session
      await _clearSession();
    } finally {
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // PASSWORD MANAGEMENT
  // ============================================================

  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      print('🟡 Requesting password reset for: $email');
      final response = await _apiService.forgotPassword(email);
      print('🟢 Password reset response: ${response.success}');
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
      print('🟡 Changing password...');
      final success = await _apiService.changePassword(currentPassword, newPassword);
      
      if (success) {
        print('🟢 Password changed successfully');
      } else {
        _error = 'Failed to change password';
        print('🔴 $_error');
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
  // FINGERPRINT MANAGEMENT
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
        print('🟢 Fingerprint enabled successfully');
      } else {
        print('🔴 Failed to enable fingerprint');
      }
      return success;
    } catch (e) {
      print('🔴 Enable fingerprint error: $e');
      return false;
    }
  }

  Future<bool> disableFingerprint() async {
    try {
      print('🟡 Disabling fingerprint...');
      
      final success = await FingerprintService.disableFingerprint();
      
      if (success) {
        await refreshFingerprintStatus();
        print('🟢 Fingerprint disabled successfully');
      } else {
        print('🔴 Failed to disable fingerprint');
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

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  bool shouldShowFingerprintLogin() {
    return _fingerprintAvailable && 
           _fingerprintEnabled && 
           _savedUserName != null &&
           _savedUserEmail != null;
  }

  String getFingerprintWelcomeMessage() {
    if (shouldShowFingerprintLogin()) {
      return 'Welcome Back, $_savedUserName!';
    }
    return 'Welcome Back!';
  }

  String getFingerprintSubtitle() {
    if (shouldShowFingerprintLogin()) {
      return 'Use fingerprint or enter your credentials';
    }
    return 'Sign in to continue to your dashboard';
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // DISPOSAL
  // ============================================================
  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}