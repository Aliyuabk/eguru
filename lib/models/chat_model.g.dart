// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: (json['id'] as num).toInt(),
      roomId: (json['roomId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      receiverId: (json['receiverId'] as num?)?.toInt(),
      messageType: json['messageType'] as String? ?? 'text',
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      mediaSize: (json['mediaSize'] as num?)?.toInt(),
      mediaSha256: json['mediaSha256'] as String?,
      gpsLat: (json['gpsLat'] as num?)?.toDouble(),
      gpsLng: (json['gpsLng'] as num?)?.toDouble(),
      isOfflineSync: json['isOfflineSync'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'messageType': instance.messageType,
      'content': instance.content,
      'mediaUrl': instance.mediaUrl,
      'mediaSize': instance.mediaSize,
      'mediaSha256': instance.mediaSha256,
      'gpsLat': instance.gpsLat,
      'gpsLng': instance.gpsLng,
      'isOfflineSync': instance.isOfflineSync,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
      id: (json['id'] as num).toInt(),
      tenantId: (json['tenantId'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String? ?? 'group',
      electionId: (json['electionId'] as num?)?.toInt(),
      jurisdictionType: json['jurisdictionType'] as String?,
      jurisdictionId: (json['jurisdictionId'] as num?)?.toInt(),
      createdBy: (json['createdBy'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'type': instance.type,
      'electionId': instance.electionId,
      'jurisdictionType': instance.jurisdictionType,
      'jurisdictionId': instance.jurisdictionId,
      'createdBy': instance.createdBy,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
