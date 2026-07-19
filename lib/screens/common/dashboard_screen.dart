import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../polling_unit_agent/pu_dashboard.dart';
import '../party_agent/party_dashboard.dart';
import '../observer/observer_dashboard.dart';
import '../volunteer/volunteer_dashboard.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: _getRoleScreen(_user.roleLevel ?? ''),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(_getRoleIcon(_user.roleLevel ?? '')),
            label: 'Tasks',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getRoleScreen(String role) {
    switch (_currentIndex) {
      case 0:
        return _getRoleDashboard(role);
      case 1:
        return _getRoleTasks(role);
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _getRoleDashboard(String role) {
    switch (role) {
      case 'pu_agent':
        return const PUDashboardScreen();
      case 'party_agent':
        return const PartyDashboardScreen();
      case 'observer':
        return const ObserverDashboardScreen();
      case 'volunteer':
        return const VolunteerDashboardScreen();
      default:
        return const PUDashboardScreen();
    }
  }

  Widget _getRoleTasks(String role) {
    // Return the appropriate tasks screen based on role
    // This will be implemented in the respective role screens
    return const Center(
      child: Text('Tasks Screen'),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'pu_agent':
        return Icons.assignment;
      case 'party_agent':
        return Icons.how_to_vote;
      case 'observer':
        return Icons.visibility;
      case 'volunteer':
        return Icons.volunteer_activism;
      default:
        return Icons.dashboard;
    }
  }
}