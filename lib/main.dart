import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/common/dashboard_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Election Monitor',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppNavigator(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Show splash screen while initializing
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }
    
    // Navigate based on authentication status
    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}