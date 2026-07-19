import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Grays
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);
  
  // Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  
  // Shadows
  static const double radius = 14.0;
  static const double headerHeight = 64.0;
  static const double sidebarWidth = 280.0;
  static const double sidebarWidthCollapsed = 80.0;
  
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowHover = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];
}

// Role-based color mapping
class RoleColors {
  static const Map<String, Color> roleColors = {
    'pu_agent': Color(0xFF2563EB),
    'party_agent': Color(0xFFDC2626),
    'observer': Color(0xFF7C3AED),
    'volunteer': Color(0xFF059669),
    'ward_coordinator': Color(0xFFD97706),
    'lga_coordinator': Color(0xFF7C3AED),
    'state_coordinator': Color(0xFF0891B2),
    'national': Color(0xFF1F2937),
  };
  
  static const Map<String, String> roleLabels = {
    'pu_agent': 'Polling Unit Agent',
    'party_agent': 'Party Agent',
    'observer': 'Observer',
    'volunteer': 'Volunteer',
    'ward_coordinator': 'Ward Coordinator',
    'lga_coordinator': 'LGA Coordinator',
    'state_coordinator': 'State Coordinator',
    'national': 'National Coordinator',
  };
  
  static const Map<String, IconData> roleIcons = {
    'pu_agent': Icons.assignment_ind,
    'party_agent': Icons.how_to_vote,
    'observer': Icons.visibility,
    'volunteer': Icons.volunteer_activism,
    'ward_coordinator': Icons.people_alt,
    'lga_coordinator': Icons.apartment,
    'state_coordinator': Icons.place,
    'national': Icons.public,
  };
}