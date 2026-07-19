import '../models/user_model.dart';

class MockApiService {
  final List<Map<String, String>> validAccounts = [
    {'email': 'agent1@gmail.com', 'role': 'pu_agent', 'role_name': 'PU Agent', 'tenant': 'Test Tenant'},
    {'email': 'agent2@gmail.com', 'role': 'party_agent', 'role_name': 'Party Agent', 'tenant': 'APC'},
    {'email': 'agent3@gmail.com', 'role': 'volunteer', 'role_name': 'Volunteer', 'tenant': 'Volunteer Org'},
    {'email': 'observer@gmail.com', 'role': 'observer', 'role_name': 'Observer', 'tenant': 'Election Observer'},
    {'email': 'test@example.com', 'role': 'pu_agent', 'role_name': 'PU Agent', 'tenant': 'Test Tenant'},
    {'email': 'aliyuabubakar11117@gmail.com', 'role': 'super_admin', 'role_name': 'Super Admin', 'tenant': 'System'},
  ];

  Future<LoginResponse> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    print('🟡 Mock login attempt: $email');
    
    // Check if email is valid and password is not empty
    final account = validAccounts.firstWhere(
      (acc) => acc['email'] == email,
      orElse: () => {},
    );
    
    if (account.isNotEmpty && password.isNotEmpty) {
      print('🟢 Mock login success: $email');
      
      final user = User(
        id: 1,
        tenantId: 14,
        userCode: 'USR000014',
        roleId: 2,
        firstName: 'Demo',
        lastName: 'User',
        fullName: 'Demo User',
        email: email,
        phone: '+2348034897638',
        roleName: account['role_name'] ?? 'User',
        roleLevel: account['role'] ?? 'pu_agent',
        tenantName: account['tenant'] ?? 'Test Tenant',
        token: 'mock_token_123',
        status: 'active',
      );
      
      return LoginResponse(
        success: true,
        message: 'Login successful',
        user: user,
        token: 'mock_token_123',
      );
    }
    
    print('🔴 Mock login failed: Invalid credentials');
    return LoginResponse(
      success: false,
      message: 'Invalid credentials. Please check your email and password.',
    );
  }
  
  Future<void> logout() async {
    print('🟡 Mock logout');
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    print('🟡 Mock forgot password: $email');
    return ForgotPasswordResponse(
      success: true,
      message: 'Password reset link sent to $email',
    );
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    print('🟡 Mock change password');
    return true;
  }
}