import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
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
  final DateTime? dateOfBirth;
  final String? roleName;
  final String? roleLevel;
  final String? tenantName;
  final bool? twoFactorEnabled;
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  bool get isPuAgent => roleLevel == 'pu_agent';
  bool get isPartyAgent => roleLevel == 'party_agent';
  bool get isObserver => roleLevel == 'observer';
  bool get isVolunteer => roleLevel == 'volunteer';
  bool get isCoordinator => roleLevel == 'lga' || roleLevel == 'ward' || roleLevel == 'state';
  bool get isSuperAdmin => roleLevel == 'super_admin';
}

@JsonSerializable()
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

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class ForgotPasswordResponse {
  final bool success;
  final String? message;
  
  ForgotPasswordResponse({
    required this.success,
    this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) => _$ForgotPasswordResponseFromJson(json);
}