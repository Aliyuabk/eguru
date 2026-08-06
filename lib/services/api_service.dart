import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/election_model.dart';
import '../models/incident_model.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'ElectionMonitorApp/1.0',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🟡 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('🟢 RESPONSE: ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('🔴 ERROR: ${error.message}');
        print('🔴 RESPONSE: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_data');
        }
        return handler.next(error);
      },
    ));
  }

  // ============================================================
  // AUTH APIS
  // ============================================================

  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🟡 ====== LOGIN REQUEST ======');
      print('🟡 Email: $email');
      print('🟡 Password length: ${password.length}');

      final response = await _dio.request(
        ApiConstants.login,
        options: Options(method: 'POST'),
        data: {'email': email.trim(), 'password': password},
      );

      print('🟢 Response status: ${response.statusCode}');
      print('🟢 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['user'];
        final token = response.data['token'] ?? '';

        if (userData != null) {
          print('🟢 User data received: $userData');
          final user = User.fromJson(userData);
          print('🟢 User parsed: ${user.displayName} (${user.roleLevel})');

          if (token.isNotEmpty) {
            await _storage.write(key: 'auth_token', value: token);
            print('🟢 Token saved');
          }
          await _storage.write(key: 'user_data', value: userData.toString());
          print('🟢 User data saved');

          return LoginResponse(
            success: true,
            message: response.data['message'] ?? 'Login successful',
            user: user,
            token: token,
          );
        } else {
          print('🔴 User data is null');
        }
      } else {
        print('🔴 Login failed: ${response.data['message']}');
      }

      return LoginResponse(
        success: false,
        message: response.data['message'] ?? 'Login failed',
      );
    } on DioException catch (e) {
      print('🔴 Dio error: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      return LoginResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error: ${e.message}',
      );
    } catch (e) {
      print('🔴 Unexpected error: $e');
      return LoginResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }
  
  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        await _dio.request(
          ApiConstants.logout,
          options: Options(method: 'POST'),
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
    }
  }
  
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      final response = await _dio.request(
        ApiConstants.forgotPassword,
        options: Options(method: 'POST'),
        data: {'email': email.trim()},
      );
      return ForgotPasswordResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } catch (e) {
      return ForgotPasswordResponse(
        success: false,
        message: 'Request failed. Please try again.',
      );
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.request(
        ApiConstants.changePassword,
        options: Options(method: 'POST'),
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> verifyToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) return false;
      
      final response = await _dio.get(
        ApiConstants.verifyToken,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // ELECTION APIS
  // ============================================================
  
  Future<List<Election>> getElections() async {
    try {
      final response = await _dio.get(ApiConstants.elections);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['elections'] ?? [];
        return data.map((json) => Election.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // ============================================================
  // POLLING UNIT APIS
  // ============================================================
  
  Future<List<PollingUnit>> getPollingUnits({int? electionId, int? wardId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (electionId != null) queryParams['election_id'] = electionId;
      if (wardId != null) queryParams['ward_id'] = wardId;
      
      final response = await _dio.get(
        ApiConstants.pollingUnits,
        queryParameters: queryParams,
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['polling_units'] ?? [];
        return data.map((json) => PollingUnit.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // ============================================================
  // CHECKLIST APIS
  // ============================================================
  
  Future<Checklist?> getChecklist(int electionId, int puId) async {
    try {
      final response = await _dio.get(
        ApiConstants.checklist,
        queryParameters: {'election_id': electionId, 'pu_id': puId},
      );
      if (response.data['success'] == true) {
        return Checklist.fromJson(response.data['checklist']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> updateChecklist(Checklist checklist) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateChecklist,
        data: checklist.toJson(),
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // ACCREDITATION APIS
  // ============================================================
  
  Future<Map<String, dynamic>?> getAccreditation(int electionId, int puId) async {
    try {
      final response = await _dio.get(
        ApiConstants.accreditation,
        queryParameters: {'election_id': electionId, 'pu_id': puId},
      );
      if (response.data['success'] == true) {
        return response.data['accreditation'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> submitAccreditation(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.submitAccreditation,
        data: data,
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // VOTE COUNT APIS
  // ============================================================
  
  Future<Map<String, dynamic>?> getVoteCount(int electionId, int puId) async {
    try {
      final response = await _dio.get(
        ApiConstants.voteCount,
        queryParameters: {'election_id': electionId, 'pu_id': puId},
      );
      if (response.data['success'] == true) {
        return response.data['vote_count'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> submitVoteCount(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.submitVoteCount,
        data: data,
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // EC8A APIS
  // ============================================================
  
  Future<Map<String, dynamic>?> uploadEC8A(FormData data) async {
    try {
      final response = await _dio.post(
        ApiConstants.uploadEC8A,
        data: data,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      if (response.data['success'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ============================================================
  // INCIDENT APIS
  // ============================================================
  
  Future<List<Incident>> getIncidents({String? status, String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      
      final response = await _dio.get(
        ApiConstants.incidents,
        queryParameters: queryParams,
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['incidents'] ?? [];
        return data.map((json) => Incident.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<Incident?> createIncident(Incident incident) async {
    try {
      final response = await _dio.post(
        ApiConstants.createIncident,
        data: incident.toJson(),
      );
      if (response.data['success'] == true) {
        return Incident.fromJson(response.data['incident']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ============================================================
  // MEDIA APIS
  // ============================================================
  
  Future<String?> uploadMedia(String filePath, String type) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'type': type,
      });
      
      final response = await _dio.post(
        ApiConstants.uploadMedia,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      
      if (response.data['success'] == true) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ============================================================
  // NOTIFICATION APIS
  // ============================================================
  
  Future<Map<String, dynamic>> getNotifications({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      
      if (response.data['success'] == true) {
        return {
          'notifications': response.data['notifications'] ?? [],
          'unread_count': response.data['unread_count'] ?? 0,
        };
      }
      return {'notifications': [], 'unread_count': 0};
    } catch (e) {
      return {'notifications': [], 'unread_count': 0};
    }
  }
  
  // ============================================================
  // PROFILE APIS
  // ============================================================
  
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      if (response.data['success'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateProfile,
        data: data,
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // CHECK-IN APIS
  // ============================================================
  
  Future<bool> checkin(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkin,
        data: data,
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> getCheckinStatus(int electionId, int puId) async {
    try {
      final response = await _dio.get(
        ApiConstants.checkinStatus,
        queryParameters: {'election_id': electionId, 'pu_id': puId},
      );
      if (response.data['success'] == true) {
        return response.data['status'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}