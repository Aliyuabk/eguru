import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../common/dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // If user is already authenticated, redirect to dashboard
    if (authProvider.isAuthenticated && !_isLoggingIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      });
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Back Button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.how_to_vote,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to your dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Email Field
                CustomTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  isEmail: true,
                  isRequired: true,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.gray400),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  isRequired: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gray400),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(
                          'Remember me',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _isLoggingIn ? null : () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        _isLoggingIn = true;
                      });
                      
                      final success = await authProvider.login(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                      
                      setState(() {
                        _isLoggingIn = false;
                      });
                      
                      if (success && mounted) {
                        // Navigate to dashboard immediately
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              authProvider.error ?? 'Login failed',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  isLoading: _isLoggingIn || authProvider.isLoading,
                ),
                
                const SizedBox(height: 20),
                
                // Demo Accounts
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Demo Accounts',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildDemoChip('PU Agent', 'agent1@gmail.com'),
                          _buildDemoChip('Party Agent', 'agent2@gmail.com'),
                          _buildDemoChip('Observer', 'observer@gmail.com'),
                          _buildDemoChip('Volunteer', 'agent3@gmail.com'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoChip(String role, String email) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = 'password123';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
        ),
        child: Text(
          role,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}