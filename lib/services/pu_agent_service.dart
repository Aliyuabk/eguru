import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_checkin.dart';
import '../models/ec8a_result.dart';
import '../models/offline_data.dart';
import '../models/polling_unit.dart';
import '../models/incident.dart';
import '../models/message.dart';
import '../models/notification.dart';

class PUAgentService {
  static const String baseUrl = 'https://eguruelction.kowagurutech.ng/api/endpoints';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== AUTHENTICATION ====================
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_data', jsonEncode(data['user']));
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // ==================== POLLING UNIT ====================

  static Future<PollingUnit?> getAssignedPollingUnit() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/polling_unit.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return PollingUnit.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching polling unit: $e');
      return null;
    }
  }

  // ==================== CHECK-IN ====================

  static Future<Map<String, dynamic>> checkIn(AgentCheckin checkin) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/checkin.php'),
        headers: headers,
        body: jsonEncode(checkin.toJson()),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<AgentCheckin>> getCheckins() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/checkins.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => AgentCheckin.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching checkins: $e');
      return [];
    }
  }

  // ==================== EC8A RESULTS ====================

  static Future<Map<String, dynamic>> submitEC8A(EC8AResult result) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/ec8a.php'),
        headers: headers,
        body: jsonEncode(result.toJson()),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<EC8AResult>> getEC8AResults() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/ec8a.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => EC8AResult.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching EC8A results: $e');
      return [];
    }
  }

  // ==================== CHECKLIST ====================

  static Future<Map<String, dynamic>> getChecklist() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/checklist.php'),
        headers: headers,
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitChecklist(Map<String, dynamic> checklist) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/checklist.php'),
        headers: headers,
        body: jsonEncode(checklist),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== ACCREDITATION ====================

  static Future<Map<String, dynamic>> submitAccreditation(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/accreditation.php'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== INCIDENTS ====================

  static Future<List<Incident>> getIncidents() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/incidents.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => Incident.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching incidents: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> reportIncident(Incident incident) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/incidents.php'),
        headers: headers,
        body: jsonEncode(incident.toJson()),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== PANIC BUTTON ====================

  static Future<Map<String, dynamic>> sendPanicAlert(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/panic.php'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== CHAT ====================

  static Future<List<Message>> getMessages() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/messages.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => Message.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> sendMessage(Message message) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/messages.php'),
        headers: headers,
        body: jsonEncode(message.toJson()),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== NOTIFICATIONS ====================

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/notifications.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> markNotificationRead(String notificationId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/notifications/read.php'),
        headers: headers,
        body: jsonEncode({'notification_id': notificationId}),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== OFFLINE SYNC ====================

  static Future<Map<String, dynamic>> saveOfflineData(OfflineData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineData = prefs.getStringList('offline_data') ?? [];
      offlineData.add(jsonEncode(data.toJson()));
      await prefs.setStringList('offline_data', offlineData);
      return {'success': true, 'message': 'Data saved offline'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<OfflineData>> getOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineData = prefs.getStringList('offline_data') ?? [];
      return offlineData
          .map((item) => OfflineData.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error fetching offline data: $e');
      return [];
    }
  }

  static Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offline_data');
  }

  static Future<Map<String, dynamic>> syncData() async {
    try {
      final offlineData = await getOfflineData();
      int synced = 0;
      int failed = 0;
      
      for (var data in offlineData) {
        final result = await _syncItem(data);
        if (result['success'] == true) {
          synced++;
        } else {
          failed++;
        }
      }
      
      return {
        'success': true,
        'message': 'Synced $synced items, $failed failed',
        'synced': synced,
        'failed': failed,
      };
    } catch (e) {
      return {'success': false, 'message': 'Sync error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _syncItem(OfflineData data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/sync.php'),
        headers: headers,
        body: jsonEncode(data.payload),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          await _removeOfflineData(data.id);
          return {'success': true};
        }
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<void> _removeOfflineData(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineData = prefs.getStringList('offline_data') ?? [];
    final updated = offlineData.where((item) {
      final data = jsonDecode(item);
      return data['id'] != id;
    }).toList();
    await prefs.setStringList('offline_data', updated);
  }

  // ==================== MEDIA UPLOAD ====================

  static Future<Map<String, dynamic>> uploadPhoto(String filePath, String type) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pu_agent/upload_media.php'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadVideo(String filePath) async {
    return uploadPhoto(filePath, 'video');
  }

  static Future<Map<String, dynamic>> uploadAudio(String filePath) async {
    return uploadPhoto(filePath, 'audio');
  }

  // ==================== PROFILE ====================

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/pu_agent/profile.php'),
        headers: headers,
        body: jsonEncode(profileData),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(Map<String, dynamic> passwordData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pu_agent/change_password.php'),
        headers: headers,
        body: jsonEncode(passwordData),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ==================== UPLOAD HISTORY ====================

  static Future<List<Map<String, dynamic>>> getUploadHistory() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pu_agent/history.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching upload history: $e');
      return [];
    }
  }
}