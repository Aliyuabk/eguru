import 'dart:convert';

class OfflineData {
  final String id;
  final String userId;
  final String deviceId;
  final String dataType;
  final int priority;
  final Map<String, dynamic> payload;
  final String? filePath;
  final int? fileSize;
  final String? fileSha256;
  final String status;
  final int retryCount;
  final int maxRetries;
  final String? lastError;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfflineData({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.dataType,
    required this.priority,
    required this.payload,
    this.filePath,
    this.fileSize,
    this.fileSha256,
    this.status = 'queued',
    this.retryCount = 0,
    this.maxRetries = 5,
    this.lastError,
    this.syncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfflineData.fromJson(Map<String, dynamic> json) {
    return OfflineData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      deviceId: json['device_id'] ?? '',
      dataType: json['data_type'] ?? '',
      priority: json['priority'] ?? 5,
      payload: json['payload_json'] != null ? jsonDecode(json['payload_json']) : {},
      filePath: json['file_path'],
      fileSize: json['file_size'],
      fileSha256: json['file_sha256'],
      status: json['status'] ?? 'queued',
      retryCount: json['retry_count'] ?? 0,
      maxRetries: json['max_retries'] ?? 5,
      lastError: json['last_error'],
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'data_type': dataType,
      'priority': priority,
      'payload_json': jsonEncode(payload),
      'file_path': filePath,
      'file_size': fileSize,
      'file_sha256': fileSha256,
      'status': status,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'last_error': lastError,
      'synced_at': syncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}