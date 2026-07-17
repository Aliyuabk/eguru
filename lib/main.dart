import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/coordinator/coordinator_dashboard.dart';
import 'screens/agent/agent_dashboard.dart';
import 'screens/party_agent/party_agent_dashboard.dart';
import 'screens/volunteer/volunteer_dashboard.dart';
import 'screens/observer/observer_dashboard.dart';
import 'models/user_role.dart';

void main() {
  runApp(const ElectionGuruApp());
}

class ElectionGuruApp extends StatelessWidget {
  const ElectionGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Election Guru',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreenWrapper(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userRole = user?.role;
    
    // Debug: Print user info
    print('🔍 User: ${user?.email}');
    print('🔍 Role ID: ${user?.roleId}');
    print('🔍 Role Level: ${user?.roleLevel}');
    print('🔍 Role: $userRole');
    
    if (user == null) {
      print('⚠️ User is null, redirecting to login');
      return const LoginScreen();
    }
    
    // Get role from role_level if available
    String roleLevel = user.roleLevel?.toLowerCase() ?? '';
    print('🔍 Role Level from DB: "$roleLevel"');
    
    // Map role_level to UserRole
    UserRole? mappedRole;
    if (roleLevel.contains('super_admin')) {
      mappedRole = UserRole.superAdmin;
    } else if (roleLevel.contains('client_admin')) {
      mappedRole = UserRole.clientAdmin;
    } else if (roleLevel.contains('national')) {
      mappedRole = UserRole.national;
    } else if (roleLevel.contains('state')) {
      mappedRole = UserRole.state;
    } else if (roleLevel.contains('senatorial')) {
      mappedRole = UserRole.senatorial;
    } else if (roleLevel.contains('federal_constituency') || roleLevel.contains('federal constituency')) {
      mappedRole = UserRole.federalConstituency;
    } else if (roleLevel.contains('lga')) {
      mappedRole = UserRole.lga;
    } else if (roleLevel.contains('ward')) {
      mappedRole = UserRole.ward;
    } else if (roleLevel.contains('pu_agent') || roleLevel.contains('polling unit')) {
      mappedRole = UserRole.puAgent;
    } else if (roleLevel.contains('party_agent') || roleLevel.contains('party')) {
      mappedRole = UserRole.partyAgent;
    } else if (roleLevel.contains('volunteer')) {
      mappedRole = UserRole.volunteer;
    } else if (roleLevel.contains('observer')) {
      mappedRole = UserRole.observer;
    } else if (roleLevel.contains('situation_room')) {
      mappedRole = UserRole.situationRoom;
    } else if (roleLevel.contains('finance_officer')) {
      mappedRole = UserRole.financeOfficer;
    } else if (roleLevel.contains('citizen')) {
      mappedRole = UserRole.citizen;
    }
    
    // Use mapped role or fallback to user.role
    final finalRole = mappedRole ?? userRole;
    print('🎯 Final Role: $finalRole');
    
    // Navigate based on role
    Widget dashboard;
    if (finalRole == UserRole.partyAgent) {
      print('✅ Redirecting to Party Agent Dashboard');
      dashboard = const PartyAgentDashboard();
    } else if (finalRole == UserRole.puAgent) {
      print('✅ Redirecting to Agent Dashboard');
      dashboard = const AgentDashboard();
    } else if (finalRole == UserRole.volunteer) {
      print('✅ Redirecting to Volunteer Dashboard');
      dashboard = const VolunteerDashboard();
    } else if (finalRole == UserRole.observer) {
      print('✅ Redirecting to Observer Dashboard');
      dashboard = const ObserverDashboard();
    } else if (finalRole == UserRole.superAdmin ||
               finalRole == UserRole.clientAdmin ||
               finalRole == UserRole.national ||
               finalRole == UserRole.state ||
               finalRole == UserRole.senatorial ||
               finalRole == UserRole.federalConstituency ||
               finalRole == UserRole.lga ||
               finalRole == UserRole.ward) {
      print('✅ Redirecting to Coordinator Dashboard');
      dashboard = const CoordinatorDashboard();
    } else {
      // Fallback to coordinator dashboard
      print('⚠️ Unknown role, redirecting to Coordinator Dashboard');
      dashboard = const CoordinatorDashboard();
    }
    
    return dashboard;
  }
}