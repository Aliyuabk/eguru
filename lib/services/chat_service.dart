import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class ChatService {
  static const String baseUrl = 'https://eguruelction.kowagurutech.ng/api/endpoints';
  
  // ============================================================
  // HEADERS
  // ============================================================
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // CONTACTS / COORDINATOR
  // ============================================================
  
  Future<ChatContactsResponse> getContacts(int roleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_contacts.php?role_id=$roleId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🟢 Chat API Response Data: $data');
        return ChatContactsResponse.fromJson(data);
      } else {
        print('🔴 Get contacts failed: ${response.statusCode} - ${response.body}');
        return ChatContactsResponse();
      }
    } catch (e) {
      print('🔴 Get contacts error: $e');
      return ChatContactsResponse();
    }
  }

  Future<Contact?> getCoordinator() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      print('🟡 Getting coordinator for agent...');
      print('🟡 Token available: ${token.isNotEmpty}');
      
      // Simplified: Just call the coordinator endpoint directly
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_coordinator.php'),
        headers: headers,
      );
      
      print('🟡 Chat API Request: GET /chat/get_coordinator.php');
      print('🟢 Chat API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🟢 Chat API Response Data: $data');
        print('🟡 Get coordinator response: $data');
        
        if (data['success'] == true && data['coordinator'] != null) {
          return Contact.fromJson(data['coordinator']);
        }
        return null;
      } else {
        print('🔴 Get coordinator failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('🔴 Get coordinator error: $e');
      return null;
    }
  }

  // ============================================================
  // MESSAGES
  // ============================================================
  
  Future<List<ChatMessage>> getMessages(int contactId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_messages.php?contact_id=$contactId'),
        headers: headers,
      );
      
      print('🟡 Chat API Request: GET /chat/get_messages.php');
      print('🟡 Request Data: null');
      print('🟢 Chat API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🟢 Chat API Response Data: $data');
        print('🟡 Get messages response: $data');
        
        if (data['success'] == true && data['messages'] != null) {
          final List messages = data['messages'];
          return messages.map((e) => ChatMessage.fromJson(e)).toList();
        }
        return [];
      } else {
        print('🔴 Get messages failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('🔴 Get messages error: $e');
      return [];
    }
  }

  Future<List<ChatMessage>> getMessagesSince(int contactId, int lastMsgId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_messages.php?contact_id=$contactId&last_msg_id=$lastMsgId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['messages'] != null) {
          final List messages = data['messages'];
          return messages.map((e) => ChatMessage.fromJson(e)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      print('🔴 Get messages since error: $e');
      return [];
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================
  
  Future<ChatMessage?> sendMessage(
    int receiverId,
    String message,
    String messageType, {
    double? gpsLat,
    double? gpsLng,
  }) async {
    try {
      final headers = await _getHeaders();
      final requestData = {
        'receiver_id': receiverId,
        'message': message,
        'message_type': messageType,
        if (gpsLat != null) 'gps_lat': gpsLat.toString(),
        if (gpsLng != null) 'gps_lng': gpsLng.toString(),
      };
      
      print('🟡 Sending message to: $receiverId');
      print('🟡 Content: $message');
      print('🟡 Type: $messageType');
      print('🟡 Chat API Request: POST /chat/send_message.php');
      print('🟡 Request Data: $requestData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send_message.php'),
        headers: headers,
        body: jsonEncode(requestData),
      );
      
      print('🟢 Chat API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🟢 Chat API Response Data: $data');
        print('🟢 Send message response: $data');
        
        if (data['success'] == true && data['data'] != null) {
          return ChatMessage.fromJson(data['data']);
        }
        return null;
      } else {
        print('🔴 Send message failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('🔴 Send message error: $e');
      return null;
    }
  }

  // ============================================================
  // SEND FILE
  // ============================================================
  
  Future<ChatMessage?> sendFile(
    int receiverId,
    String filePath,
    String fileName,
    int fileSize,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/upload_file.php'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['receiver_id'] = receiverId.toString();
      request.fields['message_type'] = 'file';
      request.fields['filename'] = fileName;
      request.fields['filesize'] = fileSize.toString();
      
      final file = await http.MultipartFile.fromPath(
        'attachment',
        filePath,
        contentType: MediaType('application', 'octet-stream'),
      );
      request.files.add(file);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        if (data['success'] == true && data['message'] != null) {
          final fileInfo = {
            'filename': fileName,
            'filesize': fileSize,
            'filetype': fileName.split('.').last,
            'url': data['url'],
          };
          
          return await sendMessage(
            receiverId,
            jsonEncode(fileInfo),
            'file',
          );
        }
        return null;
      }
      return null;
    } catch (e) {
      print('🔴 Send file error: $e');
      return null;
    }
  }

  // ============================================================
  // SEND IMAGE
  // ============================================================
  
  Future<ChatMessage?> sendImage(
    int receiverId,
    String imagePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/upload_file.php'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['receiver_id'] = receiverId.toString();
      request.fields['message_type'] = 'image';
      
      final file = await http.MultipartFile.fromPath(
        'attachment',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        if (data['success'] == true && data['message'] != null) {
          return await sendMessage(
            receiverId,
            '',
            'image',
          );
        }
        return null;
      }
      return null;
    } catch (e) {
      print('🔴 Send image error: $e');
      return null;
    }
  }

  // ============================================================
  // MARK AS READ
  // ============================================================
  
  Future<bool> markAsRead(int contactId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chat/mark_read.php'),
        headers: headers,
        body: jsonEncode({
          'contact_id': contactId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('🔴 Mark as read error: $e');
      return false;
    }
  }
}