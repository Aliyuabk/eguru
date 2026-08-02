import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PartyObservationsScreen extends StatelessWidget {
  const PartyObservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildObservationCard(
            'Voting Process',
            'Voting is proceeding smoothly at Kangire P.S',
            '2026-07-19 10:30',
            'pending',
          ),
          _buildObservationCard(
            'Material Check',
            'All materials are present and in good condition',
            '2026-07-19 09:15',
            'submitted',
          ),
          _buildObservationCard(
            'Accreditation',
            'Accreditation process is orderly and peaceful',
            '2026-07-18 16:00',
            'approved',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create observation
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildObservationCard(String title, String description, String date, String status) {
    Color statusColor;
    switch (status) {
      case 'submitted':
        statusColor = AppColors.warning;
        break;
      case 'approved':
        statusColor = AppColors.success;
        break;
      case 'rejected':
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
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