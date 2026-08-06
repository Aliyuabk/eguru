import 'dart:convert';
import 'package:flutter/material.dart';  // ✅ ADD THIS - fixes Colors.grey

class User {
  final int id;
  final int? tenantId;
  final String userCode;
  final int roleId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? photographUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? roleName;
  final String? roleLevel;
  final String? tenantName;
  final int? twoFactorEnabled;
  final String? token;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? jurisdictionType;
  final int? jurisdictionId;
  final int? wardId;
  final int? lgaId;
  final int? stateId;
  final int? senatorialId;
  final int? federalConstituencyId;
  final String? puName;
  final String? puCode;
  final int? puId;
  final int? electionId;

  User({
    required this.id,
    this.tenantId,
    required this.userCode,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.email,
    this.phone,
    this.avatar,
    this.photographUrl,
    this.gender,
    this.dateOfBirth,
    this.roleName,
    this.roleLevel,
    this.tenantName,
    this.twoFactorEnabled,
    this.token,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.jurisdictionType,
    this.jurisdictionId,
    this.wardId,
    this.lgaId,
    this.stateId,
    this.senatorialId,
    this.federalConstituencyId,
    this.puName,
    this.puCode,
    this.puId,
    this.electionId,
  });

  // ============================================================
  // FACTORY METHODS WITH SAFE PARSING
  // ============================================================

  /// Safe integer parser - handles all possible input types
  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      return parsed ?? defaultValue;
    }
    if (value is bool) return value ? 1 : 0;
    return defaultValue;
  }

  /// Safe string parser
  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value.trim();
    if (value is int || value is double || value is bool) {
      return value.toString();
    }
    return defaultValue;
  }

  /// Safe boolean parser
  static bool _safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final cleaned = value.trim().toLowerCase();
      if (cleaned == '1' || cleaned == 'true') return true;
      if (cleaned == '0' || cleaned == 'false') return false;
    }
    return defaultValue;
  }

  /// Create User from JSON with comprehensive error handling
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('🟢 Parsing User from JSON...');
      
      // Log the raw data for debugging
      if (json['id'] != null) {
        print('🟢 User ID: ${json['id']} (${json['id'].runtimeType})');
      }
      if (json['role_level'] != null) {
        print('🟢 Role Level: ${json['role_level']} (${json['role_level'].runtimeType})');
      }

      return User(
        id: _safeInt(json['id']),
        tenantId: _safeInt(json['tenant_id']),
        userCode: _safeString(json['user_code']),
        roleId: _safeInt(json['role_id']),
        firstName: _safeString(json['first_name']),
        lastName: _safeString(json['last_name']),
        fullName: _safeString(json['full_name'], defaultValue: ''),
        email: _safeString(json['email']),
        phone: _safeString(json['phone']),
        avatar: _safeString(json['avatar']),
        photographUrl: _safeString(json['photograph_url']),
        gender: _safeString(json['gender']),
        dateOfBirth: _safeString(json['date_of_birth']),
        roleName: _safeString(json['role_name']),
        roleLevel: _safeString(json['role_level']),
        tenantName: _safeString(json['tenant_name']),
        twoFactorEnabled: _safeInt(json['two_factor_enabled']),
        token: _safeString(json['token']),
        status: _safeString(json['status'], defaultValue: 'active'),
        createdAt: _safeString(json['created_at']),
        updatedAt: _safeString(json['updated_at']),
        jurisdictionType: _safeString(json['jurisdiction_type']),
        jurisdictionId: _safeInt(json['jurisdiction_id']),
        wardId: _safeInt(json['ward_id']),
        lgaId: _safeInt(json['lga_id']),
        stateId: _safeInt(json['state_id']),
        senatorialId: _safeInt(json['senatorial_id']),
        federalConstituencyId: _safeInt(json['federal_constituency_id']),
        puName: _safeString(json['pu_name']),
        puCode: _safeString(json['pu_code']),
        puId: _safeInt(json['pu_id']),
        electionId: _safeInt(json['election_id']),
      );
    } catch (e, stackTrace) {
      print('🔴 ERROR in User.fromJson: $e');
      print('🔴 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'user_code': userCode,
      'role_id': roleId,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'photograph_url': photographUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'role_name': roleName,
      'role_level': roleLevel,
      'tenant_name': tenantName,
      'two_factor_enabled': twoFactorEnabled,
      'token': token,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'jurisdiction_type': jurisdictionType,
      'jurisdiction_id': jurisdictionId,
      'ward_id': wardId,
      'lga_id': lgaId,
      'state_id': stateId,
      'senatorial_id': senatorialId,
      'federal_constituency_id': federalConstituencyId,
      'pu_name': puName,
      'pu_code': puCode,
      'pu_id': puId,
      'election_id': electionId,
    };
  }

  /// Convert to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create User from JSON string
  static User fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return User.fromJson(json);
    } catch (e) {
      print('🔴 ERROR parsing User from JSON string: $e');
      rethrow;
    }
  }

  // ============================================================
  // HELPER PROPERTIES
  // ============================================================

  bool get isPuAgent => roleLevel == 'pu_agent';
  bool get isPartyAgent => roleLevel == 'party_agent';
  bool get isObserver => roleLevel == 'observer';
  bool get isVolunteer => roleLevel == 'volunteer';
  bool get isCoordinator => [
    'lga', 'ward', 'state', 'national', 'super_admin', 
    'senatorial', 'federal_constituency'
  ].contains(roleLevel);
  bool get isSuperAdmin => roleLevel == 'super_admin';
  bool get isClientAdmin => roleLevel == 'client_admin';
  bool get isNational => roleLevel == 'national';
  bool get isSenatorial => roleLevel == 'senatorial';
  bool get isFederalConstituency => roleLevel == 'federal_constituency';
  bool get isLgaCoordinator => roleLevel == 'lga';
  bool get isWardCoordinator => roleLevel == 'ward';
  bool get isStateCoordinator => roleLevel == 'state';

  bool get isMobileRole => [
    'pu_agent', 'party_agent', 'observer', 'volunteer'
  ].contains(roleLevel);

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  bool get isPending => status == 'pending';
  bool get isArchived => status == 'archived';

  String get displayName => fullName.isNotEmpty ? fullName : '$firstName $lastName';
  
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get roleDisplayName {
    switch (roleLevel) {
      case 'pu_agent': return 'Polling Unit Agent';
      case 'party_agent': return 'Party Agent';
      case 'observer': return 'Observer';
      case 'volunteer': return 'Volunteer';
      case 'lga': return 'LGA Coordinator';
      case 'ward': return 'Ward Coordinator';
      case 'state': return 'State Coordinator';
      case 'national': return 'National Coordinator';
      case 'super_admin': return 'Super Administrator';
      case 'client_admin': return 'Client Administrator';
      case 'senatorial': return 'Senatorial Coordinator';
      case 'federal_constituency': return 'Federal Constituency Coordinator';
      default: return roleName ?? 'User';
    }
  }

  String get redirectUrl {
    return 'https://eguruelection.kowagurutech.ng/admin/dashboard.php';
  }

  // ✅ This now works because we imported 'package:flutter/material.dart'
  Color get roleColor {
    switch (roleLevel) {
      case 'pu_agent': return const Color(0xFF2563EB);
      case 'party_agent': return const Color(0xFFDC2626);
      case 'observer': return const Color(0xFF7C3AED);
      case 'volunteer': return const Color(0xFF059669);
      default: return Colors.grey;
    }
  }
}

// ============================================================
// LOGIN RESPONSE
// ============================================================

class LoginResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? token;
  final bool? requires2fa;

  LoginResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.requires2fa,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🟢 Parsing LoginResponse...');
      print('🟢 Success: ${json['success']}');
      print('🟢 Has User: ${json['user'] != null}');
      print('🟢 Has Token: ${json['token'] != null}');

      User? user;
      if (json['user'] != null) {
        try {
          user = User.fromJson(json['user']);
        } catch (e) {
          print('🔴 Failed to parse user in LoginResponse: $e');
          // Don't rethrow - we want to return a response even if user parsing fails
        }
      }

      return LoginResponse(
        success: json['success'] ?? false,
        message: _safeString(json['message']),
        user: user,
        token: _safeString(json['token']),
        requires2fa: json['requires_2fa'] ?? false,
      );
    } catch (e) {
      print('🔴 ERROR in LoginResponse.fromJson: $e');
      return LoginResponse(
        success: false,
        message: 'Failed to parse response: $e',
      );
    }
  }

  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value.trim();
    if (value is int || value is double || value is bool) {
      return value.toString();
    }
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'requires_2fa': requires2fa,
    };
  }

  /// Convert to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create LoginResponse from JSON string
  static LoginResponse fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return LoginResponse.fromJson(json);
    } catch (e) {
      print('🔴 ERROR parsing LoginResponse from JSON string: $e');
      return LoginResponse(
        success: false,
        message: 'Failed to parse stored session data: $e',
      );
    }
  }
}

// ============================================================
// FORGOT PASSWORD RESPONSE
// ============================================================

class ForgotPasswordResponse {
  final bool success;
  final String? message;

  ForgotPasswordResponse({
    required this.success,
    this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}