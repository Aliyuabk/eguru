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
    return ChatMessage(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'],
      messageType: json['message_type'] ?? 'text',
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      mediaSize: json['media_size'],
      mediaSha256: json['media_sha256'],
      gpsLat: json['gps_lat'] != null ? double.tryParse(json['gps_lat'].toString()) : null,
      gpsLng: json['gps_lng'] != null ? double.tryParse(json['gps_lng'].toString()) : null,
      isOfflineSync: json['is_offline_sync'] == 1,
      isDeleted: json['is_deleted'] == 1,
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] == 1,
      readAt: json['read_at'],
      senderFirstName: json['sender_first_name'],
      senderLastName: json['sender_last_name'],
      senderPhoto: json['sender_photo'],
      receiverName: json['receiver_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_type': messageType,
      'content': content,
      'media_url': mediaUrl,
      'media_size': mediaSize,
      'media_sha256': mediaSha256,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'is_offline_sync': isOfflineSync ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
      'is_read': (isRead == true) ? 1 : 0, // Fixed: properly check nullable bool
      'read_at': readAt,
    };
  }
  
  String get senderName {
    if (senderFirstName != null && senderLastName != null) {
      return '$senderFirstName $senderLastName';
    }
    return 'Unknown User';
  }
  
  String get timeDisplay {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return createdAt;
    }
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
    return ChatRoom(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'group',
      electionId: json['election_id'],
      jurisdictionType: json['jurisdiction_type'],
      jurisdictionId: json['jurisdiction_id'],
      createdBy: json['created_by'] ?? 0,
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'] ?? '',
      memberCount: json['member_count'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'type': type,
      'election_id': electionId,
      'jurisdiction_type': jurisdictionType,
      'jurisdiction_id': jurisdictionId,
      'created_by': createdBy,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }
  
  String get lastMessageTimeDisplay {
    if (lastMessageTime == null) return '';
    try {
      final dateTime = DateTime.parse(lastMessageTime!);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 7) {
        return '${difference.inDays}d';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Now';
      }
    } catch (e) {
      return '';
    }
  }
}

// ============================================================
// CONTACT CLASS
// ============================================================

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
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      photographUrl: json['photograph_url'],
      roleId: json['role_id'] ?? 0,
      roleName: json['role_name'],
      roleLevel: json['role_level'],
      puName: json['pu_name'],
      puCode: json['pu_code'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] == 1,
      lastLoginAt: json['last_login_at'],
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

// ============================================================
// CHAT CONTACTS RESPONSE
// ============================================================

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