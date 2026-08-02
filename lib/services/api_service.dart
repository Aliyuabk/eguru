import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/election_model.dart';
import '../models/incident_model.dart';
import '../models/chat_model.dart';

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
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      logPrint: (object) {
        print(object.toString());
      },
    ));
    
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🟡 REQUEST URL: ${options.baseUrl}${options.path}');
        print('🟡 REQUEST METHOD: ${options.method}');
        print('🟡 REQUEST HEADERS: ${options.headers}');
        print('🟡 REQUEST DATA: ${options.data}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🟢 RESPONSE STATUS: ${response.statusCode}');
        print('🟢 RESPONSE DATA: ${response.data}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔴 ERROR: ${error.message}');
        print('🔴 ERROR TYPE: ${error.type}');
        print('🔴 ERROR RESPONSE: ${error.response?.data}');
        print('🔴 ERROR STATUS: ${error.response?.statusCode}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_data');
        }
        return handler.next(error);
      },
    ));
  }
  
  // ============================================================
  // TEST METHODS
  // ============================================================
  
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await _dio.get('/test.php');
      print('🟢 Test connection: ${response.data}');
      return response.data;
    } catch (e) {
      print('🔴 Test connection failed: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> testPostRequest() async {
    try {
      print('🟡 Testing POST request to /auth/test_post.php');
      
      final response = await _dio.request(
        '/auth/test_post.php',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'email': 'test@example.com',
          'password': 'test123',
          'test': true,
        },
      );
      
      print('🟢 Test response: ${response.data}');
      return response.data;
    } catch (e) {
      print('🔴 Test POST failed: $e');
      rethrow;
    }
  }
  
  // ============================================================
  // AUTH APIs
  // ============================================================
  
  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🟡 ATTEMPTING LOGIN for: $email');
      print('🟡 Password length: ${password.length}');
      
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return LoginResponse(
          success: false,
          message: 'Email and password are required',
        );
      }
      
      // Create request data
      final Map<String, String> requestData = {
        'email': email.trim(),
        'password': password,
      };
      
      print('🟡 Request data: $requestData');
      
      // Make the POST request - explicitly set method
      final response = await _dio.request(
        ApiConstants.login,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: requestData,
      );
      
      print('🟢 Login response status: ${response.statusCode}');
      
      // Check if response is valid
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if data is null
        if (data == null) {
          print('🔴 Response data is null');
          return LoginResponse(
            success: false,
            message: 'Server returned empty response',
          );
        }
        
        print('🟢 Login response data: $data');
        
        // Check if success is true
        if (data['success'] == true) {
          final userData = data['user'];
          final token = data['token'] ?? '';
          
          if (userData != null) {
            try {
              print('🟢 User data: $userData');
              final user = User.fromJson(userData);
              
              // Save token and user data
              if (token.isNotEmpty) {
                await _storage.write(key: 'auth_token', value: token);
              }
              await _storage.write(key: 'user_data', value: userData.toString());
              
              return LoginResponse(
                success: true,
                message: data['message'] ?? 'Login successful',
                user: user,
                token: token,
              );
            } catch (e) {
              print('🔴 Error parsing user data: $e');
              return LoginResponse(
                success: false,
                message: 'Error parsing user data: ${e.toString()}',
              );
            }
          } else {
            print('🔴 User data not found in response');
            return LoginResponse(
              success: false,
              message: 'User data not found in response',
            );
          }
        } else {
          final message = data['message'] ?? 'Login failed';
          print('🔴 Login failed: $message');
          return LoginResponse(
            success: false,
            message: message,
          );
        }
      } else {
        print('🔴 Server error: ${response.statusCode}');
        return LoginResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('🔴 Dio error: ${e.message}');
      print('🔴 Dio error type: ${e.type}');
      print('🔴 Dio error response: ${e.response?.data}');
      
      // Handle different error types
      if (e.response != null) {
        final data = e.response?.data;
        final message = data != null && data is Map && data['message'] != null 
            ? data['message'] 
            : 'Login failed: ${e.response?.statusCode}';
        return LoginResponse(
          success: false,
          message: message,
        );
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        return LoginResponse(
          success: false,
          message: 'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return LoginResponse(
          success: false,
          message: 'Cannot connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        return LoginResponse(
          success: false,
          message: 'Server returned an error response.',
        );
      } else {
        return LoginResponse(
          success: false,
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      print('🔴 Unexpected error: $e');
      print('🔴 Error type: ${e.runtimeType}');
      return LoginResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
  
  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        await _dio.request(
          ApiConstants.logout,
          options: Options(
            method: 'POST',
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
        print('🟢 Logout API call successful');
      }
    } catch (e) {
      print('🔴 Logout error: $e');
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
      print('🟢 Auth data cleared from storage');
    }
  }
  
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
  try {
    print('🟡 Forgot password request for: $email');
    
    final response = await _dio.request(
      ApiConstants.forgotPassword,
      options: Options(
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: {'email': email.trim()},
    );
    
    print('🟢 Forgot password response: ${response.data}');
    
    return ForgotPasswordResponse(
      success: response.data['success'] ?? false,
      message: response.data['message'],
    );
  } on DioException catch (e) {
    print('🔴 Forgot password error: ${e.message}');
    return ForgotPasswordResponse(
      success: false,
      message: e.response?.data['message'] ?? 'Request failed. Please try again.',
    );
  }
}
  
Future<bool> changePassword(String currentPassword, String newPassword) async {
  try {
    print('🟡 Change password request');
    print('🟡 Current password length: ${currentPassword.length}');
    print('🟡 New password length: ${newPassword.length}');
    
    final response = await _dio.request(
      ApiConstants.changePassword,
      options: Options(
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    
    print('🟢 Change password response: ${response.data}');
    
    // Check if response indicates success
    if (response.data['success'] == true) {
      return true;
    } else {
      // Return false with error message
      final message = response.data['message'] ?? 'Failed to change password';
      print('🔴 Change password failed: $message');
      return false;
    }
  } on DioException catch (e) {
    print('🔴 Change password error: ${e.message}');
    print('🔴 Response data: ${e.response?.data}');
    
    // Extract error message from response
    if (e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        print('🔴 Error message: ${data['message']}');
      }
    }
    return false;
  } catch (e) {
    print('🔴 Change password error: $e');
    return false;
  }
}
  
  Future<bool> verifyToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        return false;
      }
      
      final response = await _dio.request(
        ApiConstants.verifyToken,
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Verify token error: $e');
      return false;
    }
  }
  
  // ============================================================
  // ELECTION APIs
  // ============================================================
  
  Future<List<Election>> getElections() async {
    try {
      print('🟡 Getting elections');
      
      final response = await _dio.get(
        ApiConstants.elections,
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get elections response: ${response.data}');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['elections'] ?? [];
        return data.map((json) => Election.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 Get elections error: $e');
      return [];
    }
  }
  
  Future<Election?> getElection(int id) async {
    try {
      print('🟡 Getting election: $id');
      
      final response = await _dio.get(
        '${ApiConstants.election}?id=$id',
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get election response: ${response.data}');
      
      if (response.data['success'] == true) {
        return Election.fromJson(response.data['election']);
      }
      return null;
    } catch (e) {
      print('🔴 Get election error: $e');
      return null;
    }
  }
  
  // ============================================================
  // POLLING UNIT APIs
  // ============================================================
  
  Future<List<PollingUnit>> getPollingUnits({int? electionId, int? wardId}) async {
    try {
      print('🟡 Getting polling units');
      
      final queryParams = <String, dynamic>{};
      if (electionId != null) queryParams['election_id'] = electionId;
      if (wardId != null) queryParams['ward_id'] = wardId;
      
      final response = await _dio.get(
        ApiConstants.pollingUnits,
        queryParameters: queryParams,
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get polling units response: ${response.data}');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['polling_units'] ?? [];
        return data.map((json) => PollingUnit.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 Get polling units error: $e');
      return [];
    }
  }
  
  Future<PollingUnit?> getPollingUnit(int id) async {
    try {
      print('🟡 Getting polling unit: $id');
      
      final response = await _dio.get(
        '${ApiConstants.pollingUnit}?id=$id',
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get polling unit response: ${response.data}');
      
      if (response.data['success'] == true) {
        return PollingUnit.fromJson(response.data['polling_unit']);
      }
      return null;
    } catch (e) {
      print('🔴 Get polling unit error: $e');
      return null;
    }
  }
  
  // ============================================================
  // CHECKLIST APIs
  // ============================================================
  
  Future<Checklist?> getChecklist(int electionId, int puId) async {
    try {
      print('🟡 Getting checklist for election: $electionId, PU: $puId');
      
      final response = await _dio.get(
        ApiConstants.checklist,
        queryParameters: {
          'election_id': electionId,
          'pu_id': puId,
        },
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get checklist response: ${response.data}');
      
      if (response.data['success'] == true) {
        return Checklist.fromJson(response.data['checklist']);
      }
      return null;
    } catch (e) {
      print('🔴 Get checklist error: $e');
      return null;
    }
  }
  
  Future<bool> updateChecklist(Checklist checklist) async {
    try {
      print('🟡 Updating checklist');
      
      final response = await _dio.request(
        ApiConstants.updateChecklist,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: checklist.toJson(),
      );
      
      print('🟢 Update checklist response: ${response.data}');
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Update checklist error: $e');
      return false;
    }
  }
  
  // ============================================================
  // ACCREDITATION APIs
  // ============================================================
  
  Future<Map<String, dynamic>?> getAccreditation(int electionId, int puId) async {
    try {
      print('🟡 Getting accreditation for election: $electionId, PU: $puId');
      
      final response = await _dio.get(
        ApiConstants.accreditation,
        queryParameters: {
          'election_id': electionId,
          'pu_id': puId,
        },
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get accreditation response: ${response.data}');
      
      if (response.data['success'] == true) {
        return response.data['accreditation'];
      }
      return null;
    } catch (e) {
      print('🔴 Get accreditation error: $e');
      return null;
    }
  }
  
  Future<bool> submitAccreditation(Map<String, dynamic> data) async {
    try {
      print('🟡 Submitting accreditation');
      
      final response = await _dio.request(
        ApiConstants.submitAccreditation,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      
      print('🟢 Submit accreditation response: ${response.data}');
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Submit accreditation error: $e');
      return false;
    }
  }
  
  // ============================================================
  // VOTE COUNT APIs
  // ============================================================
  
  Future<Map<String, dynamic>?> getVoteCount(int electionId, int puId) async {
    try {
      print('🟡 Getting vote count for election: $electionId, PU: $puId');
      
      final response = await _dio.get(
        ApiConstants.voteCount,
        queryParameters: {
          'election_id': electionId,
          'pu_id': puId,
        },
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get vote count response: ${response.data}');
      
      if (response.data['success'] == true) {
        return response.data['vote_count'];
      }
      return null;
    } catch (e) {
      print('🔴 Get vote count error: $e');
      return null;
    }
  }
  
  Future<bool> submitVoteCount(Map<String, dynamic> data) async {
    try {
      print('🟡 Submitting vote count');
      
      final response = await _dio.request(
        ApiConstants.submitVoteCount,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      
      print('🟢 Submit vote count response: ${response.data}');
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Submit vote count error: $e');
      return false;
    }
  }
  
  // ============================================================
  // EC8A APIs
  // ============================================================
  
  Future<Map<String, dynamic>?> uploadEC8A(FormData data) async {
    try {
      print('🟡 Uploading EC8A');
      
      final response = await _dio.post(
        ApiConstants.uploadEC8A,
        data: data,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('🟢 Upload EC8A response: ${response.data}');
      
      if (response.data['success'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('🔴 Upload EC8A error: $e');
      return null;
    }
  }
  
  // ============================================================
  // INCIDENT APIs
  // ============================================================
  
  Future<List<Incident>> getIncidents({String? status, String? type}) async {
    try {
      print('🟡 Getting incidents');
      
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      
      final response = await _dio.get(
        ApiConstants.incidents,
        queryParameters: queryParams,
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get incidents response: ${response.data}');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['incidents'] ?? [];
        return data.map((json) => Incident.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 Get incidents error: $e');
      return [];
    }
  }
  
  Future<Incident?> createIncident(Incident incident) async {
    try {
      print('🟡 Creating incident');
      
      final response = await _dio.request(
        ApiConstants.createIncident,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: incident.toJson(),
      );
      
      print('🟢 Create incident response: ${response.data}');
      
      if (response.data['success'] == true) {
        return Incident.fromJson(response.data['incident']);
      }
      return null;
    } catch (e) {
      print('🔴 Create incident error: $e');
      return null;
    }
  }
  
  Future<bool> updateIncident(Incident incident) async {
    try {
      print('🟡 Updating incident: ${incident.id}');
      
      final response = await _dio.request(
        '${ApiConstants.incidents}/${incident.id}',
        options: Options(
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: incident.toJson(),
      );
      
      print('🟢 Update incident response: ${response.data}');
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Update incident error: $e');
      return false;
    }
  }
  
  // ============================================================
  // CHAT APIs
  // ============================================================
  
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      print('🟡 Getting chat rooms');
      
      final response = await _dio.get(
        ApiConstants.chatRooms,
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get chat rooms response: ${response.data}');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['rooms'] ?? [];
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 Get chat rooms error: $e');
      return [];
    }
  }
  
  Future<List<ChatMessage>> getMessages(int roomId) async {
    try {
      print('🟡 Getting messages for room: $roomId');
      
      final response = await _dio.get(
        '${ApiConstants.chatMessages}?room_id=$roomId',
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get messages response: ${response.data}');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['messages'] ?? [];
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 Get messages error: $e');
      return [];
    }
  }
  
  Future<ChatMessage?> sendMessage(int roomId, String content, String type) async {
    try {
      print('🟡 Sending message to room: $roomId');
      
      final response = await _dio.request(
        ApiConstants.sendMessage,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'room_id': roomId,
          'content': content,
          'message_type': type,
        },
      );
      
      print('🟢 Send message response: ${response.data}');
      
      if (response.data['success'] == true) {
        return ChatMessage.fromJson(response.data['message']);
      }
      return null;
    } catch (e) {
      print('🔴 Send message error: $e');
      return null;
    }
  }
  
  // ============================================================
  // MEDIA APIs
  // ============================================================
  
  Future<String?> uploadMedia(String filePath, String type) async {
    try {
      print('🟡 Uploading media: $type');
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'type': type,
      });
      
      final response = await _dio.post(
        ApiConstants.uploadMedia,
        data: formData,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('🟢 Upload media response: ${response.data}');
      
      if (response.data['success'] == true) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('🔴 Upload media error: $e');
      return null;
    }
  }
  
  // ============================================================
  // NOTIFICATION APIs
  // ============================================================
  
  Future<Map<String, dynamic>> getNotifications({int limit = 50, int offset = 0}) async {
    try {
      print('🟡 Getting notifications');
      
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get notifications response: ${response.data}');
      
      if (response.data['success'] == true) {
        return {
          'notifications': response.data['notifications'] ?? [],
          'unread_count': response.data['unread_count'] ?? 0,
        };
      }
      return {'notifications': [], 'unread_count': 0};
    } catch (e) {
      print('🔴 Get notifications error: $e');
      return {'notifications': [], 'unread_count': 0};
    }
  }
  
  Future<bool> markNotificationRead(int notificationId) async {
    try {
      print('🟡 Marking notification as read: $notificationId');
      
      final response = await _dio.request(
        '/notifications/mark_read.php',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {'notification_id': notificationId},
      );
      
      print('🟢 Mark notification read response: ${response.data}');
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Mark notification read error: $e');
      return false;
    }
  }
  
  // ============================================================
  // PROFILE APIs
  // ============================================================
  
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      print('🟡 Getting profile');
      
      final response = await _dio.get(
        ApiConstants.profile,
        options: Options(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('🟢 Get profile response: ${response.data}');
      
      if (response.data['success'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('🔴 Get profile error: $e');
      return null;
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      print('🟡 Updating profile');
      
      final response = await _dio.request(
        ApiConstants.updateProfile,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      
      print('🟢 Update profile response: ${response.data}');
      
      return response.data['success'] ?? false;
    } catch (e) {
      print('🔴 Update profile error: $e');
      return false;
    }
  }
}