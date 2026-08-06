// screens/common/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late User _user;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = authProvider.user!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getRoleDashboard(_user.roleLevel ?? ''),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRoleDashboard(String role) {
    switch (_currentIndex) {
      case 0:
        return _buildRoleDashboard(role);
      case 1:
        return const ChatScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildRoleDashboard(String role) {
    switch (role) {
      case 'pu_agent':
        return const PUAgentDashboardPlaceholder();
      case 'party_agent':
        return const PartyAgentDashboardPlaceholder();
      case 'observer':
        return const ObserverDashboardPlaceholder();
      case 'volunteer':
        return const VolunteerDashboardPlaceholder();
      default:
        return const GeneralDashboardPlaceholder();
    }
  }
}

// ============================================================
// PLACEHOLDER DASHBOARDS
// ============================================================

class PUAgentDashboardPlaceholder extends StatelessWidget {
  const PUAgentDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: 'Polling Unit Agent',
      icon: Icons.assignment_ind,
      color: AppColors.puAgentColor,
      actions: const [
        'Check-in',
        'Checklist',
        'Accreditation',
        'Vote Count',
        'Upload EC8A',
        'Upload History',
      ],
    );
  }
}

class PartyAgentDashboardPlaceholder extends StatelessWidget {
  const PartyAgentDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: 'Party Agent',
      icon: Icons.how_to_vote,
      color: AppColors.partyAgentColor,
      actions: const [
        'Observations',
        'Evidence',
        'Incident Report',
        'Upload Media',
      ],
    );
  }
}

class ObserverDashboardPlaceholder extends StatelessWidget {
  const ObserverDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: 'Observer',
      icon: Icons.visibility,
      color: AppColors.observerColor,
      actions: const [
        'Observations',
        'Incident Report',
        'Upload Media',
        'Reports',
      ],
    );
  }
}

class VolunteerDashboardPlaceholder extends StatelessWidget {
  const VolunteerDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: 'Volunteer',
      icon: Icons.volunteer_activism,
      color: AppColors.volunteerColor,
      actions: const [
        'My Tasks',
        'Community Reports',
        'Upload Media',
        'Chat',
      ],
    );
  }
}

class GeneralDashboardPlaceholder extends StatelessWidget {
  const GeneralDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: 'Dashboard',
      icon: Icons.dashboard,
      color: AppColors.primary,
      actions: const [
        'Elections',
        'Polling Units',
        'Reports',
        'Settings',
      ],
    );
  }
}

// ============================================================
// REUSABLE DASHBOARD TEMPLATE
// ============================================================

class DashboardTemplate extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> actions;

  const DashboardTemplate({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  user?.initials ?? 'U',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.firstName ?? 'User'}!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
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
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user?.puName != null && user!.puName!.isNotEmpty
                        ? 'Assigned: ${user.puName}'
                        : 'No polling unit assigned',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
                if (user?.puCode != null && user!.puCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.puCode!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Pending Tasks',
            value: '3',
            icon: Icons.pending_actions,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Submitted',
            value: '12',
            icon: Icons.check_circle_outline,
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
            color: Colors.black.withValues(alpha: 0.05),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickAction(context, action);
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title feature coming soon!'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForAction(title),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAction(String title) {
    switch (title) {
      case 'Check-in':
        return Icons.location_on;
      case 'Checklist':
        return Icons.checklist;
      case 'Accreditation':
        return Icons.assignment_ind;
      case 'Vote Count':
        return Icons.how_to_vote;
      case 'Upload EC8A':
        return Icons.upload_file;
      case 'Upload History':
        return Icons.history;
      case 'Observations':
        return Icons.visibility;
      case 'Evidence':
        return Icons.photo_library;
      case 'Incident Report':
        return Icons.warning;
      case 'Upload Media':
        return Icons.photo_camera;
      case 'My Tasks':
        return Icons.assignment;
      case 'Community Reports':
        return Icons.report;
      case 'Chat':
        return Icons.chat;
      case 'Elections':
        return Icons.how_to_vote;
      case 'Polling Units':
        return Icons.location_city;
      case 'Reports':
        return Icons.assessment;
      case 'Settings':
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          'Form Uploaded',
          'You submitted a form',
          '2 hours ago',
          Icons.upload_file,
          AppColors.success,
        ),
        _buildActivityItem(
          'Task Completed',
          'You completed a task',
          '4 hours ago',
          Icons.check_circle,
          AppColors.info,
        ),
        _buildActivityItem(
          'Report Submitted',
          'Your report was submitted',
          '6 hours ago',
          Icons.report,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
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
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}