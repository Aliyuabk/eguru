import 'package:flutter/material.dart';

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
  
  // Jurisdiction fields
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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'],
      userCode: json['user_code'] ?? '',
      roleId: json['role_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      photographUrl: json['photograph_url'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      roleName: json['role_name'],
      roleLevel: json['role_level'],
      tenantName: json['tenant_name'],
      twoFactorEnabled: json['two_factor_enabled'],
      token: json['token'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      jurisdictionType: json['jurisdiction_type'],
      jurisdictionId: json['jurisdiction_id'],
      wardId: json['ward_id'],
      lgaId: json['lga_id'],
      stateId: json['state_id'],
      senatorialId: json['senatorial_id'],
      federalConstituencyId: json['federal_constituency_id'],
      puName: json['pu_name'],
      puCode: json['pu_code'],
      puId: json['pu_id'],
    );
  }

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
    };
  }
  
  // Role Checkers
  bool get isPuAgent => roleLevel == 'pu_agent';
  bool get isPartyAgent => roleLevel == 'party_agent';
  bool get isObserver => roleLevel == 'observer';
  bool get isVolunteer => roleLevel == 'volunteer';
  bool get isCoordinator => roleLevel == 'lga' || roleLevel == 'ward' || roleLevel == 'state' || roleLevel == 'national';
  bool get isSuperAdmin => roleLevel == 'super_admin';
  bool get isClientAdmin => roleLevel == 'client_admin';
  bool get isNational => roleLevel == 'national';
  bool get isSenatorial => roleLevel == 'senatorial';
  bool get isFederalConstituency => roleLevel == 'federal_constituency';
  bool get isLgaCoordinator => roleLevel == 'lga';
  bool get isWardCoordinator => roleLevel == 'ward';
  bool get isStateCoordinator => roleLevel == 'state';
  
  // Status Checkers
  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  bool get isPending => status == 'pending';
  bool get isArchived => status == 'archived';
  
  // Display Helpers
  String get displayName => fullName.isNotEmpty ? fullName : '$firstName $lastName';
  String get initials => (firstName.isNotEmpty ? firstName[0] : '') + 
                          (lastName.isNotEmpty ? lastName[0] : '');
  
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
  
  String get tenantDisplayName => tenantName ?? 'No Tenant';
  
  String get jurisdictionDisplayName {
    if (jurisdictionType == null) return 'No Jurisdiction';
    switch (jurisdictionType) {
      case 'pu': return 'Polling Unit';
      case 'ward': return 'Ward';
      case 'lga': return 'LGA';
      case 'state': return 'State';
      case 'senatorial': return 'Senatorial';
      case 'federal_constituency': return 'Federal Constituency';
      default: return jurisdictionType!;
    }
  }
  
  int get effectiveJurisdictionId {
    if (jurisdictionId != null) return jurisdictionId!;
    if (wardId != null) return wardId!;
    if (lgaId != null) return lgaId!;
    if (stateId != null) return stateId!;
    return 0;
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
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
      requires2fa: json['requires_2fa'],
    );
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
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// ============================================================
// CHANGE PASSWORD RESPONSE
// ============================================================

class ChangePasswordResponse {
  final bool success;
  final String? message;
  
  ChangePasswordResponse({
    required this.success,
    this.message,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// ============================================================
// USER UPDATE REQUEST
// ============================================================

class UserUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? residentialAddress;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  
  UserUpdateRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.residentialAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'residential_address': residentialAddress,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
    };
  }
}

// ============================================================
// USER LIST RESPONSE
// ============================================================

class UserListResponse {
  final bool success;
  final String? message;
  final List<User> users;
  final int total;
  
  UserListResponse({
    required this.success,
    this.message,
    this.users = const [],
    this.total = 0,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final usersList = json['users'] as List? ?? [];
    return UserListResponse(
      success: json['success'] ?? false,
      message: json['message'],
      users: usersList.map((e) => User.fromJson(e)).toList(),
      total: json['total'] ?? usersList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'users': users.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }
}

// ============================================================
// USER ROLE HELPERS
// ============================================================

class UserRole {
  static const String superAdmin = 'super_admin';
  static const String clientAdmin = 'client_admin';
  static const String national = 'national';
  static const String state = 'state';
  static const String senatorial = 'senatorial';
  static const String federalConstituency = 'federal_constituency';
  static const String lga = 'lga';
  static const String ward = 'ward';
  static const String puAgent = 'pu_agent';
  static const String partyAgent = 'party_agent';
  static const String observer = 'observer';
  static const String volunteer = 'volunteer';
  
  static const Map<String, String> displayNames = {
    superAdmin: 'Super Administrator',
    clientAdmin: 'Client Administrator',
    national: 'National Coordinator',
    state: 'State Coordinator',
    senatorial: 'Senatorial Coordinator',
    federalConstituency: 'Federal Constituency Coordinator',
    lga: 'LGA Coordinator',
    ward: 'Ward Coordinator',
    puAgent: 'Polling Unit Agent',
    partyAgent: 'Party Agent',
    observer: 'Observer',
    volunteer: 'Volunteer',
  };
  
  static const Map<String, IconData> icons = {
    superAdmin: Icons.admin_panel_settings,
    clientAdmin: Icons.business,
    national: Icons.public,
    state: Icons.place,
    senatorial: Icons.map,
    federalConstituency: Icons.location_city,
    lga: Icons.apartment,
    ward: Icons.people_alt,
    puAgent: Icons.assignment_ind,
    partyAgent: Icons.how_to_vote,
    observer: Icons.visibility,
    volunteer: Icons.volunteer_activism,
  };
  
  static const Map<String, Color> colors = {
    superAdmin: Color(0xFF7C3AED),
    clientAdmin: Color(0xFF2563EB),
    national: Color(0xFF1F2937),
    state: Color(0xFF0891B2),
    senatorial: Color(0xFF6D28D9),
    federalConstituency: Color(0xFF059669),
    lga: Color(0xFFD97706),
    ward: Color(0xFF0D9488),
    puAgent: Color(0xFF2563EB),
    partyAgent: Color(0xFFDC2626),
    observer: Color(0xFF7C3AED),
    volunteer: Color(0xFF059669),
  };
  
  static String getDisplayName(String role) {
    return displayNames[role] ?? role;
  }
  
  static IconData getIcon(String role) {
    return icons[role] ?? Icons.person;
  }
  
  static Color getColor(String role) {
    return colors[role] ?? Colors.grey;
  }
  
  static List<String> getCoordinatorRoles() {
    return [lga, ward, state, national, senatorial, federalConstituency];
  }
  
  static List<String> getAgentRoles() {
    return [puAgent, partyAgent, observer, volunteer];
  }
  
  static bool isCoordinator(String role) {
    return getCoordinatorRoles().contains(role);
  }
  
  static bool isAgent(String role) {
    return getAgentRoles().contains(role);
  }
}

// ============================================================
// USER STATUS HELPERS
// ============================================================

class UserStatus {
  static const String active = 'active';
  static const String suspended = 'suspended';
  static const String pending = 'pending';
  static const String archived = 'archived';
  
  static const Map<String, String> displayNames = {
    active: 'Active',
    suspended: 'Suspended',
    pending: 'Pending',
    archived: 'Archived',
  };
  
  static const Map<String, Color> colors = {
    active: Colors.green,
    suspended: Colors.red,
    pending: Colors.orange,
    archived: Colors.grey,
  };
  
  static const Map<String, IconData> icons = {
    active: Icons.check_circle,
    suspended: Icons.block,
    pending: Icons.hourglass_empty,
    archived: Icons.archive,
  };
  
  static String getDisplayName(String status) {
    return displayNames[status] ?? status;
  }
  
  static Color getColor(String status) {
    return colors[status] ?? Colors.grey;
  }
  
  static IconData getIcon(String status) {
    return icons[status] ?? Icons.circle;
  }
}