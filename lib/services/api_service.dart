import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/election_model.dart';
import '../models/incident_model.dart';
import '../models/chat_model.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_data');
        }
        return handler.next(error);
      },
    ));
  }
  
  // Auth APIs
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['user']);
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user_data', value: response.data['user'].toString());
        return LoginResponse(
          success: true,
          user: user,
          token: token,
        );
      } else {
        return LoginResponse(
          success: false,
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return LoginResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Login failed',
        );
      } else {
        return LoginResponse(
          success: false,
          message: 'Network error. Please check your connection.',
        );
      }
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }
  
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      
      return ForgotPasswordResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ForgotPasswordResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Request failed',
      );
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
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
  
  // Election APIs
  Future<List<Election>> getElections() async {
    try {
      final response = await _dio.get(ApiConstants.elections);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['elections'];
        return data.map((json) => Election.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<Election?> getElection(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.elections}/$id');
      if (response.data['success'] == true) {
        return Election.fromJson(response.data['election']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Polling Unit APIs
  Future<PollingUnit?> getPollingUnit(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.pollingUnits}/$id');
      if (response.data['success'] == true) {
        return PollingUnit.fromJson(response.data['polling_unit']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Checklist APIs
  Future<Checklist?> getChecklist(int electionId, int puId) async {
    try {
      final response = await _dio.get(
        ApiConstants.checklist,
        queryParameters: {
          'election_id': electionId,
          'pu_id': puId,
        },
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
  
  // Incident APIs
  Future<List<Incident>> getIncidents() async {
    try {
      final response = await _dio.get(ApiConstants.incidents);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['incidents'];
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
  
  Future<bool> updateIncident(Incident incident) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.incidents}/${incident.id}',
        data: incident.toJson(),
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // Chat APIs
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await _dio.get(ApiConstants.chatRooms);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['rooms'];
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<List<ChatMessage>> getMessages(int roomId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.chatRooms}/$roomId/messages',
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['messages'];
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<ChatMessage?> sendMessage(int roomId, String content, String type) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.chatRooms}/$roomId/messages',
        data: {
          'content': content,
          'message_type': type,
        },
      );
      if (response.data['success'] == true) {
        return ChatMessage.fromJson(response.data['message']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Media Upload APIs
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
}