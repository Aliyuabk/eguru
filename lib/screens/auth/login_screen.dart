import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../common/dashboard_screen.dart';
import '../common/web_redirect_screen.dart';
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
  bool _isFingerprintLogin = false;

  @override
  void initState() {
    super.initState();
    _checkFingerprintStatus();
  }

  Future<void> _checkFingerprintStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshFingerprintStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isAuthenticated && !_isLoggingIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authProvider.isMobileRole) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WebRedirectScreen()),
          );
        }
      });
    }
    
    final bool showFingerprintLogin = authProvider.fingerprintAvailable && 
                                       authProvider.fingerprintEnabled &&
                                       authProvider.savedUserName != null;
    
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
                const SizedBox(height: 40),
                
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
                        showFingerprintLogin && authProvider.savedUserName != null
                            ? 'Welcome Back, ${authProvider.savedUserName}!'
                            : 'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        showFingerprintLogin 
                            ? 'Use fingerprint or enter your credentials'
                            : 'Sign in to continue to your dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                if (showFingerprintLogin) ...[
                  _buildFingerprintLoginButton(authProvider),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.gray300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.gray500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.gray300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
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
                
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  isRequired: true,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gray400),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.gray400,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
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
                
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: authProvider.clearError,
                          child: Icon(Icons.close, color: AppColors.danger, size: 16),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
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
                        if (_rememberMe && authProvider.fingerprintAvailable) {
                          _showEnableFingerprintDialog(context, authProvider);
                        }
                        
                        if (authProvider.isMobileRole) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const WebRedirectScreen()),
                          );
                        }
                      }
                    }
                  },
                  isLoading: _isLoggingIn || authProvider.isLoading,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintLoginButton(AuthProvider authProvider) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.fingerprint,
              size: 40,
            ),
            color: AppColors.primary,
            onPressed: _isFingerprintLogin ? null : () async {
              setState(() {
                _isFingerprintLogin = true;
              });
              
              final success = await authProvider.loginWithFingerprint();
              
              setState(() {
                _isFingerprintLogin = false;
              });
              
              if (success && mounted) {
                if (authProvider.isMobileRole) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const WebRedirectScreen()),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to login with fingerprint',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ),
        if (_isFingerprintLogin) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  void _showEnableFingerprintDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Enable Fingerprint Login',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Would you like to enable fingerprint login for faster access next time?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                color: AppColors.gray600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await authProvider.enableFingerprint(
                authProvider.user?.email ?? '',
                authProvider.user?.fullName ?? '',
              );
              
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success 
                        ? 'Fingerprint login enabled successfully!' 
                        : 'Failed to enable fingerprint login',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: success ? AppColors.success : AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Enable',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}