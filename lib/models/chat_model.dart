import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final int? receiverId;
  final String messageType;
  final String content;
  final String? mediaUrl;
  final int? mediaSize;
  final String? mediaSha256;
  final double? gpsLat;
  final double? gpsLng;
  final bool isOfflineSync;
  final bool isDeleted;
  final DateTime createdAt;
  
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.receiverId,
    this.messageType = 'text',
    required this.content,
    this.mediaUrl,
    this.mediaSize,
    this.mediaSha256,
    this.gpsLat,
    this.gpsLng,
    this.isOfflineSync = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
  
  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isVideo => messageType == 'video';
  bool get isAudio => messageType == 'audio';
  bool get isFile => messageType == 'file';
  bool get isLocation => messageType == 'location';
}

class JsonSerializable {
  const JsonSerializable();
}

@JsonSerializable()
class ChatRoom {
  final int id;
  final int tenantId;
  final String name;
  final String type;
  final int? electionId;
  final String? jurisdictionType;
  final int? jurisdictionId;
  final int createdBy;
  final bool isActive;
  final DateTime createdAt;
  
  ChatRoom({
    required this.id,
    required this.tenantId,
    required this.name,
    this.type = 'group',
    this.electionId,
    this.jurisdictionType,
    this.jurisdictionId,
    required this.createdBy,
    this.isActive = true,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);
}