import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = [
      {
        'id': 1,
        'title': 'Election Update',
        'message': 'Voting has started at Kangire P.S',
        'time': '2 hours ago',
        'read': false,
        'icon': Icons.how_to_vote,
        'color': AppColors.primary,
      },
      {
        'id': 2,
        'title': 'Incident Reported',
        'message': 'Violence reported at Kangire P.S',
        'time': '3 hours ago',
        'read': false,
        'icon': Icons.warning,
        'color': AppColors.danger,
      },
      {
        'id': 3,
        'title': 'Checklist Complete',
        'message': 'Your election checklist has been approved',
        'time': '1 day ago',
        'read': true,
        'icon': Icons.check_circle,
        'color': AppColors.success,
      },
      {
        'id': 4,
        'title': 'New Message',
        'message': 'Ward Coordinator sent a message',
        'time': '1 day ago',
        'read': true,
        'icon': Icons.message,
        'color': AppColors.info,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['read'] = true;
                }
              });
            },
            child: Text(
              'Mark All Read',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;
    final color = notification['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.primaryLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? AppColors.gray200 : AppColors.primaryLight.withValues(alpha: 0.2),
        ),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    color: isRead ? AppColors.gray600 : AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['time'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}