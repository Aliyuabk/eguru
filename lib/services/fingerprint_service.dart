// services/fingerprint_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _fingerprintKey = 'fingerprint_enabled';
  static const String _deviceIdKey = 'device_id';
  static const String _userEmailKey = 'saved_user_email';
  static const String _userNameKey = 'saved_user_name';
  
  // Check if device supports fingerprint
  static Future<bool> isFingerprintAvailable() async {
    try {
      // Check if device can check biometrics
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      
      // Check if device supports biometrics
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      print('🟢 Fingerprint available: $isAvailable, Device supported: $isDeviceSupported');
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('🔴 Fingerprint availability check failed: $e');
      return false;
    }
  }
  
  // Check if fingerprint is enabled for the current user
  static Future<bool> isFingerprintEnabled() async {
    try {
      final value = await _storage.read(key: _fingerprintKey);
      return value == 'true';
    } catch (e) {
      print('🔴 Fingerprint enabled check failed: $e');
      return false;
    }
  }
  
  // Get saved user email
  static Future<String?> getSavedUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      print('🔴 Get saved user email failed: $e');
      return null;
    }
  }
  
  // Get saved user name
  static Future<String?> getSavedUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      print('🔴 Get saved user name failed: $e');
      return null;
    }
  }
  
  // Get device ID
  static Future<String?> getDeviceId() async {
    try {
      String? deviceId = await _storage.read(key: _deviceIdKey);
      if (deviceId == null) {
        // Generate a unique device ID if not exists
        deviceId = _generateDeviceId();
        await _storage.write(key: _deviceIdKey, value: deviceId);
      }
      return deviceId;
    } catch (e) {
      print('🔴 Get device ID failed: $e');
      return null;
    }
  }
  
  static String _generateDeviceId() {
    // Generate a unique device ID
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           _randomString(8);
  }
  
  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[DateTime.now().millisecondsSinceEpoch % chars.length];
    }
    return result;
  }
  
  // Authenticate with fingerprint
  static Future<bool> authenticateWithFingerprint({
    required String reason,
    bool stickyAuth = true,
  }) async {
    try {
      final bool isAvailable = await isFingerprintAvailable();
      if (!isAvailable) {
        print('🔴 Fingerprint not available');
        return false;
      }
      
      print('🟢 Starting fingerprint authentication...');
      
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
      
      print('🟢 Fingerprint authentication result: $authenticated');
      return authenticated;
    } catch (e) {
      print('🔴 Fingerprint authentication failed: $e');
      return false;
    }
  }
  
  // Enable fingerprint for current user
  static Future<bool> enableFingerprint({
    required String email,
    required String name,
  }) async {
    try {
      // First authenticate with fingerprint
      final bool authenticated = await authenticateWithFingerprint(
        reason: 'Enable fingerprint login for your account',
      );
      
      if (!authenticated) {
        print('🔴 User cancelled fingerprint enrollment');
        return false;
      }
      
      // Save user credentials
      await _storage.write(key: _userEmailKey, value: email);
      await _storage.write(key: _userNameKey, value: name);
      await _storage.write(key: _fingerprintKey, value: 'true');
      
      print('🟢 Fingerprint enabled successfully for $email');
      return true;
    } catch (e) {
      print('🔴 Enable fingerprint failed: $e');
      return false;
    }
  }
  
  // Disable fingerprint
  static Future<bool> disableFingerprint() async {
    try {
      // First authenticate with fingerprint
      final bool authenticated = await authenticateWithFingerprint(
        reason: 'Verify your identity to disable fingerprint login',
      );
      
      if (!authenticated) {
        print('🔴 User cancelled fingerprint disable');
        return false;
      }
      
      // Clear saved credentials
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userNameKey);
      await _storage.delete(key: _fingerprintKey);
      
      print('🟢 Fingerprint disabled successfully');
      return true;
    } catch (e) {
      print('🔴 Disable fingerprint failed: $e');
      return false;
    }
  }
  
  // Login with fingerprint
  static Future<Map<String, dynamic>?> loginWithFingerprint() async {
    try {
      // Check if fingerprint is enabled
      final bool enabled = await isFingerprintEnabled();
      if (!enabled) {
        print('🔴 Fingerprint not enabled');
        return null;
      }
      
      // Get saved credentials
      final String? email = await getSavedUserEmail();
      final String? name = await getSavedUserName();
      
      if (email == null || name == null) {
        print('🔴 Saved credentials not found');
        return null;
      }
      
      // Authenticate with fingerprint
      final bool authenticated = await authenticateWithFingerprint(
        reason: 'Login to your account with fingerprint',
        stickyAuth: true,
      );
      
      if (!authenticated) {
        print('🔴 Fingerprint authentication failed');
        return null;
      }
      
      // Return user data
      print('🟢 Fingerprint login successful for $email');
      return {
        'email': email,
        'name': name,
      };
    } catch (e) {
      print('🔴 Fingerprint login failed: $e');
      return null;
    }
  }
}