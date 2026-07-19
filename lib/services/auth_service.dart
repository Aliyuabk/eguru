import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // ==================== USER METHODS ====================
  
  Future<void> saveUser(User user) async {
    try {
      final userJson = user.toJson().toString();
      await _storage.write(key: 'user_data', value: userJson);
      print('🟢 User saved to storage: ${user.email}');
    } catch (e) {
      print('🔴 Error saving user: $e');
      rethrow;
    }
  }
  
  Future<User?> getUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null && userData.isNotEmpty) {
        try {
          // Parse the JSON string to Map
          final Map<String, dynamic> json = Map<String, dynamic>.from(
            userData as Map,
          );
          return User.fromJson(json);
        } catch (e) {
          print('🔴 Error parsing user data: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('🔴 Error reading user: $e');
      return null;
    }
  }
  
  Future<void> deleteUser() async {
    try {
      await _storage.delete(key: 'user_data');
      print('🟢 User deleted from storage');
    } catch (e) {
      print('🔴 Error deleting user: $e');
      rethrow;
    }
  }
  
  // ==================== TOKEN METHODS ====================
  
  Future<void> saveToken(String token) async {
    try {
      if (token.isNotEmpty) {
        await _storage.write(key: 'auth_token', value: token);
        print('🟢 Token saved to storage');
      } else {
        print('🟡 Warning: Empty token, not saving');
      }
    } catch (e) {
      print('🔴 Error saving token: $e');
      rethrow;
    }
  }
  
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        print('🟢 Token retrieved from storage');
        return token;
      }
      print('🟡 No token found in storage');
      return null;
    } catch (e) {
      print('🔴 Error reading token: $e');
      return null;
    }
  }
  
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      print('🟢 Token deleted from storage');
    } catch (e) {
      print('🔴 Error deleting token: $e');
      rethrow;
    }
  }
  
  Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('🔴 Error checking token: $e');
      return false;
    }
  }
  
  // ==================== AUTH STATUS METHODS ====================
  
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getUser();
      return token != null && token.isNotEmpty && user != null;
    } catch (e) {
      print('🔴 Error checking login status: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getAuthData() async {
    try {
      final token = await getToken();
      final user = await getUser();
      return {
        'token': token,
        'user': user,
        'isLoggedIn': token != null && user != null,
      };
    } catch (e) {
      print('🔴 Error getting auth data: $e');
      return {
        'token': null,
        'user': null,
        'isLoggedIn': false,
      };
    }
  }
  
  // ==================== REMEMBER ME METHODS ====================
  
  Future<void> saveRememberMe(String email, String password) async {
    try {
      await _storage.write(key: 'remember_email', value: email);
      await _storage.write(key: 'remember_password', value: password);
      await _storage.write(key: 'remember_me', value: 'true');
      print('🟢 Remember me saved');
    } catch (e) {
      print('🔴 Error saving remember me: $e');
      rethrow;
    }
  }
  
  Future<Map<String, String>> getRememberedCredentials() async {
    try {
      final email = await _storage.read(key: 'remember_email') ?? '';
      final password = await _storage.read(key: 'remember_password') ?? '';
      final rememberMe = await _storage.read(key: 'remember_me') == 'true';
      
      if (rememberMe && email.isNotEmpty) {
        print('🟢 Remember me credentials retrieved');
        return {
          'email': email,
          'password': password,
          'rememberMe': 'true',
        };
      }
      return {
        'email': '',
        'password': '',
        'rememberMe': 'false',
      };
    } catch (e) {
      print('🔴 Error getting remembered credentials: $e');
      return {
        'email': '',
        'password': '',
        'rememberMe': 'false',
      };
    }
  }
  
  Future<bool> hasRememberMe() async {
    try {
      final remember = await _storage.read(key: 'remember_me');
      return remember == 'true';
    } catch (e) {
      print('🔴 Error checking remember me: $e');
      return false;
    }
  }
  
  Future<void> deleteRememberMe() async {
    try {
      await _storage.delete(key: 'remember_email');
      await _storage.delete(key: 'remember_password');
      await _storage.delete(key: 'remember_me');
      print('🟢 Remember me deleted');
    } catch (e) {
      print('🔴 Error deleting remember me: $e');
      rethrow;
    }
  }
  
  // ==================== CLEAR ALL DATA METHODS ====================
  
  Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
      print('🟢 All storage data cleared');
    } catch (e) {
      print('🔴 Error clearing all data: $e');
      rethrow;
    }
  }
  
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      await deleteUser();
      await deleteRememberMe();
      print('🟢 All auth data cleared');
    } catch (e) {
      print('🔴 Error clearing auth data: $e');
      rethrow;
    }
  }
  
  // ==================== SESSION METHODS ====================
  
  Future<void> refreshToken(String newToken) async {
    try {
      await saveToken(newToken);
      print('🟢 Token refreshed');
    } catch (e) {
      print('🔴 Error refreshing token: $e');
      rethrow;
    }
  }
  
  Future<void> updateUser(User user) async {
    try {
      await saveUser(user);
      print('🟢 User updated in storage');
    } catch (e) {
      print('🔴 Error updating user: $e');
      rethrow;
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;
      
      // Optional: Check token expiration by decoding JWT
      // For now, just check if token exists
      return true;
    } catch (e) {
      print('🔴 Error validating token: $e');
      return false;
    }
  }
  
  Future<void> saveAuthData(User user, String token) async {
    try {
      await saveUser(user);
      await saveToken(token);
      print('🟢 Auth data saved successfully');
    } catch (e) {
      print('🔴 Error saving auth data: $e');
      rethrow;
    }
  }
}