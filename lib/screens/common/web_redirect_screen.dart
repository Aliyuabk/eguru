import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class WebRedirectScreen extends StatelessWidget {
  const WebRedirectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final redirectUrl = authProvider.redirectUrl;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Access Restricted',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Your account does not have mobile app access. '
                'Please use the web dashboard to access your features.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Role: ${authProvider.user?.roleDisplayName ?? 'Unknown'}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.open_in_browser, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Open Web Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      redirectUrl,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              CustomButton(
                text: 'Open Web Dashboard',
                onPressed: () async {
                  try {
                    final url = Uri.parse(redirectUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open web dashboard: $e'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                text: 'Logout',
                type: ButtonType.outline,
                onPressed: () async {
                  await authProvider.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Contact your administrator if you believe this is an error.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.gray400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}