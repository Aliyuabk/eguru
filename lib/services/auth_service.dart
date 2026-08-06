import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<void> saveUser(User user) async {
    try {
      final userJson = user.toJson().toString();
      await _storage.write(key: 'user_data', value: userJson);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<User?> getUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null && userData.isNotEmpty) {
        try {
          final Map<String, dynamic> json = Map<String, dynamic>.from(
            userData as Map,
          );
          return User.fromJson(json);
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> deleteUser() async {
    try {
      await _storage.delete(key: 'user_data');
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> saveToken(String token) async {
    try {
      if (token.isNotEmpty) {
        await _storage.write(key: 'auth_token', value: token);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      return null;
    }
  }
  
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'auth_token');
    } catch (e) {
      rethrow;
    }
  }
  
  Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getUser();
      return token != null && token.isNotEmpty && user != null;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      await deleteUser();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }
}