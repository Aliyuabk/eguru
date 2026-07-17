import 'user_role.dart';

class User {
  final int id;
  final int? tenantId;
  final String userCode;
  final int roleId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final String? avatar;
  final String? residentialAddress;
  final String? gender;
  final DateTime? dateOfBirth;
  final String status;
  final DateTime? lastLoginAt;
  final String? lastLoginIp;
  final UserRole? role;
  final String? tenantName;
  final String? roleLevel;
  final String? roleName;
  final String? pollingUnit;

  User({
    required this.id,
    this.tenantId,
    required this.userCode,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar,
    this.residentialAddress,
    this.gender,
    this.dateOfBirth,
    required this.status,
    this.lastLoginAt,
    this.lastLoginIp,
    this.role,
    this.tenantName,
    this.roleLevel,
    this.roleName,
    this.pollingUnit,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Determine user role
    UserRole? userRole;
    final roleLevel = json['role_level']?.toString().toLowerCase() ?? '';
    final roleName = json['role_name']?.toString().toLowerCase() ?? '';
    
    if (roleLevel == 'super_admin' || roleName.contains('super admin')) {
      userRole = UserRole.superAdmin;
    } else if (roleLevel == 'client_admin' || roleName.contains('client admin')) {
      userRole = UserRole.clientAdmin;
    } else if (roleLevel == 'national' || roleName.contains('national')) {
      userRole = UserRole.national;
    } else if (roleLevel == 'state' || roleName.contains('state')) {
      userRole = UserRole.state;
    } else if (roleLevel == 'senatorial' || roleName.contains('senatorial')) {
      userRole = UserRole.senatorial;
    } else if (roleLevel == 'federal_constituency' || roleName.contains('federal')) {
      userRole = UserRole.federalConstituency;
    } else if (roleLevel == 'lga' || roleName.contains('lga')) {
      userRole = UserRole.lga;
    } else if (roleLevel == 'ward' || roleName.contains('ward')) {
      userRole = UserRole.ward;
    } else if (roleLevel == 'pu_agent' || roleName.contains('polling unit')) {
      userRole = UserRole.puAgent;
    } else if (roleLevel == 'party_agent' || roleName.contains('party')) {
      userRole = UserRole.partyAgent;
    } else if (roleLevel == 'volunteer' || roleName.contains('volunteer')) {
      userRole = UserRole.volunteer;
    } else if (roleLevel == 'observer' || roleName.contains('observer')) {
      userRole = UserRole.observer;
    } else if (roleLevel == 'situation_room' || roleName.contains('situation')) {
      userRole = UserRole.situationRoom;
    } else if (roleLevel == 'finance_officer' || roleName.contains('finance')) {
      userRole = UserRole.financeOfficer;
    } else if (roleLevel == 'citizen' || roleName.contains('citizen')) {
      userRole = UserRole.citizen;
    }

    return User(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'],
      userCode: json['user_code'] ?? '',
      roleId: json['role_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? json['photograph_url'],
      residentialAddress: json['residential_address'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      status: json['status'] ?? 'pending',
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null,
      lastLoginIp: json['last_login_ip'],
      role: userRole,
      tenantName: json['tenant_name'],
      roleLevel: json['role_level'],
      roleName: json['role_name'],
      pollingUnit: json['polling_unit'],
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
      'residential_address': residentialAddress,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'status': status,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_login_ip': lastLoginIp,
      'role_level': role?.name,
      'tenant_name': tenantName,
      'polling_unit': pollingUnit,
    };
  }
}