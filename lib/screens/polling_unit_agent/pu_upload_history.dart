import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PUUploadHistoryScreen extends StatelessWidget {
  const PUUploadHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard(
            'EC8A Form',
            'Submitted',
            '2026-07-19 11:30',
            AppColors.success,
            Icons.upload_file,
          ),
          _buildHistoryCard(
            'Accreditation',
            'Pending',
            '2026-07-19 10:45',
            AppColors.warning,
            Icons.assignment_ind,
          ),
          _buildHistoryCard(
            'Vote Count',
            'Rejected',
            '2026-07-19 09:15',
            AppColors.danger,
            Icons.how_to_vote,
          ),
          _buildHistoryCard(
            'Media Upload',
            'Submitted',
            '2026-07-18 16:30',
            AppColors.success,
            Icons.photo_camera,
          ),
          _buildHistoryCard(
            'Checklist',
            'Submitted',
            '2026-07-18 14:00',
            AppColors.success,
            Icons.checklist,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    String title,
    String status,
    String date,
    Color statusColor,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.2)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          // Show details
        },
      ),
    );
  }
}