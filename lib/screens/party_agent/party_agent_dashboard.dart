import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/observations_screen.dart';
import 'screens/incidents_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

class PartyAgentDashboard extends StatefulWidget {
  const PartyAgentDashboard({super.key});

  @override
  State<PartyAgentDashboard> createState() => _PartyAgentDashboardState();
}

class _PartyAgentDashboardState extends State<PartyAgentDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ObservationsScreen(),
      const IncidentsScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    // Load unread notifications count
    try {
      // This would come from API
      setState(() {
        _unreadNotifications = 3; // Example
      });
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.gray500,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Observations',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_outlined),
            activeIcon: Icon(Icons.warning),
            label: 'Incidents',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
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
}