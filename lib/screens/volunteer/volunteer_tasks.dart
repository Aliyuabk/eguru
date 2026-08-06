import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VolunteerTasksScreen extends StatelessWidget {
  const VolunteerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTaskCard(
            'Assist at Polling Unit',
            'Help with voter registration and crowd control',
            'Kangire P.S',
            'In Progress',
          ),
          _buildTaskCard(
            'Distribute Materials',
            'Deliver election materials to assigned polling units',
            'Kangire Ward',
            'Pending',
          ),
          _buildTaskCard(
            'Monitor Accreditation',
            'Observe and report on accreditation process',
            'Kangire P.S',
            'Completed',
          ),
          _buildTaskCard(
            'Collect Reports',
            'Collect EC8A forms from polling units',
            'Kangire Ward',
            'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String description, String location, String status) {
    Color statusColor;
    switch (status) {
      case 'In Progress': statusColor = AppColors.warning; break;
      case 'Completed': statusColor = AppColors.success; break;
      default: statusColor = AppColors.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.gray400),
                const SizedBox(width: 4),
                Text(location, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}