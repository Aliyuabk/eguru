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
    };
  }
  
  bool get isPuAgent => roleLevel == 'pu_agent';
  bool get isPartyAgent => roleLevel == 'party_agent';
  bool get isObserver => roleLevel == 'observer';
  bool get isVolunteer => roleLevel == 'volunteer';
  bool get isCoordinator => roleLevel == 'lga' || roleLevel == 'ward' || roleLevel == 'state';
  bool get isSuperAdmin => roleLevel == 'super_admin';
}

class LoginResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? token;
  
  LoginResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
    };
  }
}

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