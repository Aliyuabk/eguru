import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'coordinator/coordinator_dashboard.dart';
import 'agent/agent_dashboard.dart';
import 'party_agent/party_agent_dashboard.dart';
import 'volunteer/volunteer_dashboard.dart';
import 'observer/observer_dashboard.dart';
import '../models/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    
    _controller.forward();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuthStatus();
    
    if (!mounted) return;
    
    if (isAuthenticated) {
      _navigateToDashboard(authProvider.user?.role);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToDashboard(UserRole? role) {
    if (role == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    Widget dashboard;
    switch (role) {
      case UserRole.superAdmin:
      case UserRole.clientAdmin:
      case UserRole.national:
      case UserRole.state:
      case UserRole.senatorial:
      case UserRole.federalConstituency:
      case UserRole.lga:
      case UserRole.ward:
        dashboard = const CoordinatorDashboard();
        break;
      case UserRole.puAgent:
        dashboard = const AgentDashboard();
        break;
      case UserRole.partyAgent:
        dashboard = const PartyAgentDashboard();
        break;
      case UserRole.volunteer:
        dashboard = const VolunteerDashboard();
        break;
      case UserRole.observer:
        dashboard = const ObserverDashboard();
        break;
      default:
        dashboard = const CoordinatorDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.how_to_vote,
                                  size: 60,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // App Name
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoAnimation.value,
                          child: const Column(
                            // children: [
                            //   Text(
                            //     'Election Guru',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontSize: 28,
                            //       fontWeight: FontWeight.bold,
                            //       letterSpacing: 1.2,
                            //     ),
                            //   ),
                            //   SizedBox(height: 8),
                            //   Text(
                            //     'Election Management System',
                            //     style: TextStyle(
                            //       color: Colors.white70,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w400,
                            //       letterSpacing: 0.5,
                            //     ),
                            //   ),
                            // ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Loading Indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Version
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}