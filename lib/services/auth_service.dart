import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<void> saveUser(User user) async {
    await _storage.write(key: 'user_data', value: user.toJson().toString());
  }
  
  Future<User?> getUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
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
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
  
  Future<void> clearAuthData() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'remember_me');
  }
  
  Future<void> saveRememberMe(String email, String password) async {
    await _storage.write(key: 'remember_email', value: email);
    await _storage.write(key: 'remember_password', value: password);
    await _storage.write(key: 'remember_me', value: 'true');
  }
  
  Future<Map<String, String>> getRememberedCredentials() async {
    final email = await _storage.read(key: 'remember_email') ?? '';
    final password = await _storage.read(key: 'remember_password') ?? '';
    return {
      'email': email,
      'password': password,
    };
  }
  
  Future<bool> hasRememberMe() async {
    final remember = await _storage.read(key: 'remember_me');
    return remember == 'true';
  }
}