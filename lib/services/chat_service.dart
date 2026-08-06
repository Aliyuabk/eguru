import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';

class ChatService {
  // ✅ CORRECT URL - fixed spelling
  static const String baseUrl = 'https://guru.kowagurutech.ng/api/endpoints';
  
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
        return ChatContactsResponse.fromJson(data);
      }
      return ChatContactsResponse();
    } catch (e) {
      return ChatContactsResponse();
    }
  }

  Future<Contact?> getCoordinator() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_coordinator.php'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['coordinator'] != null) {
          return Contact.fromJson(data['coordinator']);
        }
        return null;
      }
      return null;
    } catch (e) {
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

      final response = await http.post(
        Uri.parse('$baseUrl/chat/send_message.php'),
        headers: headers,
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ChatMessage.fromJson(data['data']);
        }
        return null;
      }
      return null;
    } catch (e) {
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
        body: jsonEncode({'contact_id': contactId}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}