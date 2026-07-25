import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_model.dart';

class ChatService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ChatService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) {
      // Accept all status codes to handle them manually
      return status != null && status < 500;
    },
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🟡 Chat API Request: ${options.method} ${options.path}');
        print('🟡 Request Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('🟢 Chat API Response Status: ${response.statusCode}');
        print('🟢 Chat API Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('🔴 Chat API Error: ${error.message}');
        print('🔴 Error Response: ${error.response?.data}');
        print('🔴 Error Status: ${error.response?.statusCode}');
        return handler.next(error);
      },
    ));
  }
  
  // ============================================================
  // FOR PU AGENT, OBSERVER, VOLUNTEER - GET THEIR COORDINATOR
  // ============================================================
  
  Future<Contact?> getCoordinator() async {
    try {
      final response = await _dio.get(
        '/chat/get_coordinator.php',
      );
      
      print('🟡 Get coordinator response: ${response.data}');
      
      if (response.statusCode == 200 && 
          response.data['success'] == true && 
          response.data['coordinator'] != null) {
        return Contact.fromJson(response.data['coordinator']);
      }
      
      print('🔴 Get coordinator failed: ${response.data['message'] ?? 'Unknown error'}');
      return null;
      
    } on DioException catch (e) {
      print('🔴 Get coordinator Dio error: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('🔴 Get coordinator error: $e');
      return null;
    }
  }
  
  // ============================================================
  // FOR WARD COORDINATOR - GET CONTACTS BY ROLE
  // ============================================================
  
  Future<ChatContactsResponse> getContacts(int roleId) async {
    try {
      final response = await _dio.get(
        '/chat/get_contacts.php',
        queryParameters: {
          'role_id': roleId,
        },
      );
      
      print('🟡 Get contacts response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ChatContactsResponse.fromJson(response.data);
      }
      
      print('🔴 Get contacts failed: ${response.data['message'] ?? 'Unknown error'}');
      return ChatContactsResponse();
      
    } on DioException catch (e) {
      print('🔴 Get contacts Dio error: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      return ChatContactsResponse();
    } catch (e) {
      print('🔴 Get contacts error: $e');
      return ChatContactsResponse();
    }
  }
  
  // ============================================================
  // GET MESSAGES BETWEEN TWO USERS
  // ============================================================
  
  Future<List<ChatMessage>> getMessages(int contactId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/chat/get_messages.php',
        queryParameters: {
          'contact_id': contactId,
          'limit': limit,
          'offset': offset,
        },
      );
      
      print('🟡 Get messages response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['messages'] ?? [];
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      
      print('🔴 Get messages failed: ${response.data['message'] ?? 'Unknown error'}');
      return [];
      
    } on DioException catch (e) {
      print('🔴 Get messages Dio error: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      return [];
    } catch (e) {
      print('🔴 Get messages error: $e');
      return [];
    }
  }
  
  // ============================================================
  // SEND A MESSAGE
  // ============================================================
  
  Future<ChatMessage?> sendMessage(int receiverId, String content, String type, {String? mediaUrl}) async {
    try {
      print('🟡 Sending message to: $receiverId');
      print('🟡 Content: ${content.length > 50 ? content.substring(0, 50) + '...' : content}');
      print('🟡 Type: $type');
      
      final Map<String, dynamic> data = {
        'receiver_id': receiverId,
        'message': content,
        'message_type': type,
      };
      
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        data['media_url'] = mediaUrl;
      }
      
      final response = await _dio.post(
        '/chat/send_message.php',
        data: data,
      );
      
      print('🟢 Send message response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          return ChatMessage.fromJson(response.data['data']);
        }
        return null;
      } else {
        final message = response.data['message'] ?? 'Failed to send message';
        print('🔴 Send message failed: $message');
        return null;
      }
      
    } on DioException catch (e) {
      print('🔴 Send message Dio error: ${e.message}');
      print('🔴 Error Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('🔴 Send message error: $e');
      return null;
    }
  }
  
  // ============================================================
  // UPLOAD FILE
  // ============================================================
  
  Future<String?> uploadFile(String filePath, String type) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'type': type,
      });
      
      final response = await _dio.post(
        '/chat/upload_file.php',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      
      print('🟡 Upload file response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['url'];
      }
      
      print('🔴 Upload file failed: ${response.data['message'] ?? 'Unknown error'}');
      return null;
      
    } on DioException catch (e) {
      print('🔴 Upload file Dio error: ${e.message}');
      return null;
    } catch (e) {
      print('🔴 Upload file error: $e');
      return null;
    }
  }
  
  // ============================================================
  // MARK MESSAGES AS READ
  // ============================================================
  
  Future<bool> markAsRead(int contactId) async {
    try {
      final response = await _dio.post(
        '/chat/mark_read.php',
        data: {
          'contact_id': contactId,
        },
      );
      
      print('🟡 Mark as read response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      print('🔴 Mark as read failed: ${response.data['message'] ?? 'Unknown error'}');
      return false;
      
    } on DioException catch (e) {
      print('🔴 Mark as read Dio error: ${e.message}');
      return false;
    } catch (e) {
      print('🔴 Mark as read error: $e');
      return false;
    }
  }
  
  // ============================================================
  // GET UNREAD COUNT
  // ============================================================
  
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(
        '/chat/get_unread_count.php',
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['unread_count'] ?? 0;
      }
      return 0;
      
    } catch (e) {
      print('🔴 Get unread count error: $e');
      return 0;
    }
  }
  
  // ============================================================
  // CREATE OR GET CHAT ROOM
  // ============================================================
  
  Future<int?> getOrCreateRoom(int contactId) async {
    try {
      final response = await _dio.post(
        '/chat/get_room.php',
        data: {
          'contact_id': contactId,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['room_id'];
      }
      return null;
      
    } catch (e) {
      print('🔴 Get room error: $e');
      return null;
    }
  }
  
  // ============================================================
  // CHECK IF COORDINATOR EXISTS
  // ============================================================
  
  Future<bool> hasCoordinator() async {
    try {
      final response = await _dio.get(
        '/chat/get_coordinator.php',
      );
      
      if (response.statusCode == 200 && 
          response.data['success'] == true && 
          response.data['coordinator'] != null) {
        return true;
      }
      return false;
      
    } catch (e) {
      print('🔴 Has coordinator error: $e');
      return false;
    }
  }
  
  // ============================================================
  // GET COORDINATOR WITH RETRY
  // ============================================================
  
  Future<Contact?> getCoordinatorWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      print('🟡 Attempt $attempt of $maxRetries to get coordinator');
      
      final coordinator = await getCoordinator();
      if (coordinator != null) {
        return coordinator;
      }
      
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    print('🔴 Failed to get coordinator after $maxRetries attempts');
    return null;
  }
}