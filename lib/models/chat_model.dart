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
  final String createdAt;
  final bool? isRead;
  final String? readAt;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderPhoto;
  final String? receiverName;
  
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
    this.isRead,
    this.readAt,
    this.senderFirstName,
    this.senderLastName,
    this.senderPhoto,
    this.receiverName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Safe int parser
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ChatMessage(
      id: safeInt(json['id']),
      roomId: safeInt(json['room_id']),
      senderId: safeInt(json['sender_id']),
      receiverId: safeInt(json['receiver_id']),
      messageType: json['message_type']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString(),
      mediaSize: safeInt(json['media_size']),
      mediaSha256: json['media_sha256']?.toString(),
      gpsLat: json['gps_lat'] != null ? double.tryParse(json['gps_lat'].toString()) : null,
      gpsLng: json['gps_lng'] != null ? double.tryParse(json['gps_lng'].toString()) : null,
      isOfflineSync: json['is_offline_sync'] == 1 || json['is_offline_sync'] == '1',
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == '1',
      createdAt: json['created_at']?.toString() ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == '1',
      readAt: json['read_at']?.toString(),
      senderFirstName: json['sender_first_name']?.toString(),
      senderLastName: json['sender_last_name']?.toString(),
      senderPhoto: json['sender_photo']?.toString(),
      receiverName: json['receiver_name']?.toString(),
    );
  }

  String get senderName {
    if (senderFirstName != null && senderLastName != null) {
      return '$senderFirstName $senderLastName';
    }
    return 'Unknown User';
  }
}

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
  final String createdAt;
  final int? memberCount;
  final String? lastMessage;
  final String? lastMessageTime;
  final int? unreadCount;

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
    this.memberCount,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ChatRoom(
      id: safeInt(json['id']),
      tenantId: safeInt(json['tenant_id']),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'group',
      electionId: safeInt(json['election_id']),
      jurisdictionType: json['jurisdiction_type']?.toString(),
      jurisdictionId: safeInt(json['jurisdiction_id']),
      createdBy: safeInt(json['created_by']),
      isActive: json['is_active'] == 1 || json['is_active'] == '1',
      createdAt: json['created_at']?.toString() ?? '',
      memberCount: safeInt(json['member_count']),
      lastMessage: json['last_message']?.toString(),
      lastMessageTime: json['last_message_time']?.toString(),
      unreadCount: safeInt(json['unread_count']),
    );
  }
}

class Contact {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? photographUrl;
  final int roleId;
  final String? roleName;
  final String? roleLevel;
  final String? puName;
  final String? puCode;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? lastLoginAt;
  final int? puId;

  Contact({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.photographUrl,
    required this.roleId,
    this.roleName,
    this.roleLevel,
    this.puName,
    this.puCode,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastLoginAt,
    this.puId,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Contact(
      id: safeInt(json['id']),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      photographUrl: json['photograph_url']?.toString(),
      roleId: safeInt(json['role_id']),
      roleName: json['role_name']?.toString(),
      roleLevel: json['role_level']?.toString(),
      puName: json['pu_name']?.toString(),
      puCode: json['pu_code']?.toString(),
      lastMessage: json['last_message']?.toString(),
      lastMessageTime: json['last_message_time']?.toString(),
      unreadCount: safeInt(json['unread_count']),
      isOnline: json['is_online'] == 1 || json['is_online'] == '1',
      lastLoginAt: json['last_login_at']?.toString(),
      puId: safeInt(json['pu_id']),
    );
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  String get lastMessageDisplay {
    if (lastMessage == null || lastMessage!.isEmpty) {
      return 'No messages yet';
    }
    return lastMessage!.length > 50
        ? '${lastMessage!.substring(0, 50)}...'
        : lastMessage!;
  }
}

class ChatContactsResponse {
  final List<Contact> contacts;
  final int total;
  final int unreadCount;
  
  ChatContactsResponse({
    this.contacts = const [],
    this.total = 0,
    this.unreadCount = 0,
  });

  factory ChatContactsResponse.fromJson(Map<String, dynamic> json) {
    final contactsList = json['contacts'] as List? ?? [];
    return ChatContactsResponse(
      contacts: contactsList.map((e) => Contact.fromJson(e)).toList(),
      total: json['total'] ?? contactsList.length,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}