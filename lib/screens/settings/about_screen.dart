import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'About',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Logo/Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.how_to_vote,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'Election Monitor',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Version
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(
                'Version $_appVersion (Build $_buildNumber)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.gray500,
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Tagline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Secure • Reliable • Real-time',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description Card
            _buildCard(
              icon: Icons.info_outline,
              title: 'About This App',
              children: [
                Text(
                  'Election Monitor is a comprehensive mobile application designed for election monitoring and management. It provides real-time data collection, reporting, and communication tools for election observers, agents, and coordinators.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.gray600,
                    height: 1.6,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Features Card
            _buildCard(
              icon: Icons.stars,
              title: 'Key Features',
              children: [
                _buildFeatureItem(
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  title: 'Real-time Data Collection',
                  description: 'Collect and submit election data instantly',
                ),
                _buildFeatureItem(
                  icon: Icons.visibility,
                  color: AppColors.info,
                  title: 'Election Monitoring',
                  description: 'Monitor election activities in real-time',
                ),
                _buildFeatureItem(
                  icon: Icons.chat,
                  color: AppColors.secondary,
                  title: 'Secure Communication',
                  description: 'Chat with coordinators and team members',
                ),
                _buildFeatureItem(
                  icon: Icons.warning,
                  color: AppColors.danger,
                  title: 'Incident Reporting',
                  description: 'Report and track election incidents',
                ),
                _buildFeatureItem(
                  icon: Icons.assessment,
                  color: Colors.purple,
                  title: 'Result Management',
                  description: 'Submit and verify election results',
                ),
                _buildFeatureItem(
                  icon: Icons.offline_bolt,
                  color: Colors.orange,
                  title: 'Offline Capability',
                  description: 'Work seamlessly without internet connection',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Developer Info Card
            _buildCard(
              icon: Icons.business,
              title: 'Developer Information',
              children: [
                _buildInfoRow('Developer', 'Kowaguru Tech Ltd'),
                _buildDivider(),
                _buildInfoRow('Email', 'kowagurutechltd@gmail.com'),
                _buildDivider(),
                _buildInfoRow('Website', 'www.kowagurutech.ng'),
                _buildDivider(),
                _buildInfoRow('Support', 'support@kowagurutech.ng'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Social Links Card
            _buildCard(
              icon: Icons.share,
              title: 'Connect With Us',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      icon: Icons.web,
                      label: 'Website',
                      color: AppColors.primary,
                      onTap: () => _launchUrl('https://kowagurutech.ng'),
                    ),
                    _buildSocialButton(
                      icon: Icons.email,
                      label: 'Email',
                      color: AppColors.danger,
                      onTap: () => _launchUrl('mailto:kowagurutechltd@gmail.com'),
                    ),
                    _buildSocialButton(
                      icon: Icons.phone,
                      label: 'Call',
                      color: AppColors.success,
                      onTap: () => _launchUrl('tel:+2349027702002'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Column(
              children: [
                Text(
                  '© 2026 Kowaguru Tech Ltd',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All rights reserved.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray800,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.gray200,
      height: 1,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}