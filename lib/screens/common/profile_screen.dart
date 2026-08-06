// screens/common/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../auth/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoggingOut
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 20),
                  _buildStatsRow(user),
                  const SizedBox(height: 20),
                  _buildPersonalInfoCard(user),
                  const SizedBox(height: 20),
                  _buildSettingsCard(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(authProvider),
                  const SizedBox(height: 16),
                  _buildAppVersion(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              user?.initials ?? 'U',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'User Name',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@example.com',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.roleDisplayName ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(User? user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tenant',
            value: user?.tenantName?.split(' ').first ?? 'N/A',
            icon: Icons.business,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Phone',
            value: user?.phone ?? 'N/A',
            icon: Icons.phone,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Full Name', user?.fullName ?? ''),
          const Divider(color: AppColors.gray200, height: 1),
          _buildInfoItem('Email', user?.email ?? ''),
          const Divider(color: AppColors.gray200, height: 1),
          _buildInfoItem('Phone', user?.phone ?? ''),
          const Divider(color: AppColors.gray200, height: 1),
          _buildInfoItem('Role', user?.roleDisplayName ?? ''),
          const Divider(color: AppColors.gray200, height: 1),
          _buildInfoItem('Tenant', user?.tenantName ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.gray800,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.settings, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
              ],
            ),
          ),
          _buildActionItem(
            Icons.lock_outline,
            'Change Password',
            'Update your password',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(color: AppColors.gray200, height: 1, indent: 16, endIndent: 16),
          _buildActionItem(
            Icons.fingerprint,
            'Fingerprint Login',
            'Enable/disable fingerprint login',
            () {
              _showFingerprintSettingsDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showFingerprintSettingsDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Fingerprint Login',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              authProvider.fingerprintEnabled
                  ? 'Fingerprint login is currently enabled.'
                  : 'Fingerprint login is currently disabled.',
              style: GoogleFonts.inter(),
            ),
            if (authProvider.fingerprintAvailable) ...[
              const SizedBox(height: 8),
              Text(
                authProvider.fingerprintEnabled
                    ? 'Tap "Disable" to turn it off.'
                    : 'Tap "Enable" to turn it on.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Fingerprint is not available on this device.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.danger,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          if (authProvider.fingerprintAvailable)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = authProvider.fingerprintEnabled
                    ? await authProvider.disableFingerprint()
                    : await authProvider.enableFingerprint(
                        authProvider.user?.email ?? '',
                        authProvider.user?.fullName ?? '',
                      );
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? authProvider.fingerprintEnabled
                              ? 'Fingerprint login enabled!'
                              : 'Fingerprint login disabled!'
                          : 'Operation failed',
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
                backgroundColor: authProvider.fingerprintEnabled 
                    ? AppColors.danger 
                    : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                authProvider.fingerprintEnabled ? 'Disable' : 'Enable',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.gray800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.gray500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return CustomButton(
      text: 'Logout',
      type: ButtonType.danger,
      onPressed: _isLoggingOut ? null : () => _showLogoutDialog(authProvider),
      isLoading: _isLoggingOut,
    );
  }

  Future<void> _showLogoutDialog(AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray800),
            ),
            const SizedBox(height: 8),
            Text(
              'You will need to login again to access your dashboard.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.gray500)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Logout', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _performLogout(authProvider);
    }
  }

  Future<void> _performLogout(AuthProvider authProvider) async {
    setState(() => _isLoggingOut = true);
    
    try {
      await authProvider.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray400),
      ),
    );
  }
}