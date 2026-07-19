import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Mark all as read
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotification(
            'Election Update',
            'Voting has started at Kangire P.S',
            '2 hours ago',
            false,
            Icons.how_to_vote,
            AppColors.primary,
          ),
          _buildNotification(
            'Incident Reported',
            'Violence reported at Kangire P.S',
            '3 hours ago',
            false,
            Icons.warning,
            AppColors.danger,
          ),
          _buildNotification(
            'Checklist Complete',
            'Your election checklist has been approved',
            '1 day ago',
            true,
            Icons.check_circle,
            AppColors.success,
          ),
          _buildNotification(
            'New Message',
            'Ward Coordinator sent a message',
            '1 day ago',
            true,
            Icons.message,
            AppColors.info,
          ),
          _buildNotification(
            'EC8A Uploaded',
            'EC8A form has been verified',
            '2 days ago',
            true,
            Icons.upload_file,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(
    String title,
    String message,
    String time,
    bool isRead,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? Colors.white : AppColors.primaryLight.withOpacity(0.05),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // Open notification
        },
      ),
    );
  }
}