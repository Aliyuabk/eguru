// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/common/dashboard_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/common/web_redirect_screen.dart';
import 'services/permission_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize permissions
  await _initializePermissions();
  
  // Run the app
  runApp(const MyApp());
}

/// Initialize permissions with error handling
Future<void> _initializePermissions() async {
  try {
    print('📱 Initializing permissions...');
    final permissions = await PermissionService.initializePermissions();
    print('📱 Permissions initialized: $permissions');
  } catch (e) {
    print('🔴 Failed to initialize permissions: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider - handles authentication state
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Election Monitor',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        
        // Home screen - handled by AppNavigator
        home: const AppNavigator(),
        
        // Named routes for navigation
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/web-redirect': (context) => const WebRedirectScreen(),
        },
        
        // ✅ CORRECT ERROR HANDLING - Use builder
        builder: (context, child) {
          // Override the default ErrorWidget
          ErrorWidget.builder = (FlutterErrorDetails details) {
            // Log the error
            print('🔴 Flutter Error: ${details.exception}');
            print('🔴 Stack trace: ${details.stack}');
            
            // Return a custom error widget
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'An error occurred. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Reload the app
                          // You can use a Navigator.pushReplacement or a keyed app restart
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          
          return child ?? const SizedBox.shrink();
        },
        
        // ✅ Alternative: Use onGenerateTitle for dynamic title
        onGenerateTitle: (context) => 'Election Monitor',
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showSplash = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and show splash screen
  Future<void> _initializeApp() async {
    try {
      // Show splash for at least 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      setState(() {
        _showSplash = false;
        _isInitialized = true;
      });
    } catch (e) {
      print('🔴 Error in app initialization: $e');
      if (mounted) {
        setState(() {
          _showSplash = false;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get auth provider
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Show splash screen while loading or during splash delay
    if (!authProvider.isInitialized || _showSplash) {
      return const SplashScreen();
    }
    
    // Handle different authentication states
    return _buildNavigation(authProvider);
  }

  /// Build the appropriate screen based on auth state
  Widget _buildNavigation(AuthProvider authProvider) {
    // Not authenticated - go to login
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }
    
    // Authenticated - check role
    if (authProvider.user == null) {
      // User data is missing - force re-login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _forceLogout(context);
      });
      return const LoginScreen();
    }
    
    // Check if user has a mobile role
    if (authProvider.isMobileRole) {
      return const DashboardScreen();
    } else {
      return const WebRedirectScreen();
    }
  }

  /// Force logout when user data is invalid
  void _forceLogout(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.logout();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session expired. Please login again.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      print('🔴 Error during force logout: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}