import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VolunteerReportsScreen extends StatelessWidget {
  const VolunteerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            'Voter Turnout',
            'High voter turnout observed at Kangire P.S',
            '2026-07-19',
            'Submitted',
          ),
          _buildReportCard(
            'Security Concern',
            'Suspicious activity reported near polling unit',
            '2026-07-18',
            'Approved',
          ),
          _buildReportCard(
            'Material Shortage',
            'Shortage of ballot papers reported',
            '2026-07-18',
            'Rejected',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create report
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReportCard(String title, String description, String date, String status) {
    Color statusColor;
    switch (status) {
      case 'Approved':
        statusColor = AppColors.success;
        break;
      case 'Submitted':
        statusColor = AppColors.warning;
        break;
      case 'Rejected':
        statusColor = AppColors.danger;
        break;
      default:
        statusColor = AppColors.gray500;
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}