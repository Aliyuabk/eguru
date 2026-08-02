import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart'; // Add this import
import '../auth/login_screen.dart';
import '../auth/change_password_screen.dart';
import '../settings/notification_settings_screen.dart';
import '../settings/language_screen.dart';
import '../settings/about_screen.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _isLoggingOut
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Logging out...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(user),
                  
                  const SizedBox(height: 20),
                  
                  // Stats Row
                  _buildStatsRow(user),
                  
                  const SizedBox(height: 20),
                  
                  // Personal Info Card
                  _buildPersonalInfoCard(user),
                  
                  const SizedBox(height: 20),
                  
                  // Settings Card
                  _buildSettingsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  _buildLogoutButton(authProvider),
                  
                  const SizedBox(height: 16),
                  
                  // App Version
                  _buildAppVersion(),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ==================== PROFILE HEADER ====================
  
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
          // Avatar
          _buildAvatar(user),
          const SizedBox(height: 16),
          _buildUserName(user),
          const SizedBox(height: 4),
          _buildUserEmail(user),
          const SizedBox(height: 12),
          _buildStatusBadges(user),
        ],
      ),
    );
  }

  Widget _buildAvatar(User? user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: user?.photographUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user!.photographUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Text(
                      user.firstName[0],
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Text(
                  user?.firstName[0] ?? 'U',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: AppColors.primary,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserName(User? user) {
    return Text(
      user?.fullName ?? 'User Name',
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserEmail(User? user) {
    return Text(
      user?.email ?? 'email@example.com',
      style: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildStatusBadges(User? user) {
    return Row(
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
            user?.roleName ?? 'User',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STATS ROW ====================
  
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
      decoration: _cardDecoration(),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
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

  // ==================== PERSONAL INFO CARD ====================
  
  Widget _buildPersonalInfoCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information', Icons.person_outline),
          const SizedBox(height: 12),
          _buildInfoItem('Full Name', user?.fullName ?? ''),
          _buildDivider(),
          _buildInfoItem('Email', user?.email ?? ''),
          _buildDivider(),
          _buildInfoItem('Phone', user?.phone ?? ''),
          _buildDivider(),
          _buildInfoItem('Role', user?.roleName ?? ''),
          _buildDivider(),
          _buildInfoItem('Tenant', user?.tenantName ?? ''),
        ],
      ),
    );
  }

  // ==================== SETTINGS CARD ====================
  
  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSectionHeader('Settings', Icons.settings),
          ),
          _buildActionItem(
            Icons.lock_outline,
            'Change Password',
            'Update your password',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionItem(
            Icons.notifications_none,
            'Notification Settings',
            'Manage notification preferences',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionItem(
            Icons.language,
            'Language',
            'Change app language',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionItem(
            Icons.info_outline,
            'About',
            'App information and version',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== LOGOUT BUTTON ====================
  
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will need to login again to access your dashboard.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _performLogout(authProvider);
    }
  }

  Future<void> _performLogout(AuthProvider authProvider) async {
    setState(() {
      _isLoggingOut = true;
    });
    
    try {
      // Perform logout
      await authProvider.logout();
      
      // Navigate to login screen with pushAndRemoveUntil
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error during logout: $e',
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // ==================== APP VERSION ====================
  
  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.gray400,
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
      ],
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

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
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
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.gray400,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.gray200,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}