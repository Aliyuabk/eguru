import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PollingUnitCard extends StatelessWidget {
  final String name;
  final String code;
  final String ward;
  final String lga;
  final String state;
  final String election;
  final String coordinator;

  const PollingUnitCard({
    super.key,
    required this.name,
    required this.code,
    required this.ward,
    required this.lga,
    required this.state,
    required this.election,
    required this.coordinator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.location_on,
                color: AppTheme.primary,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ward: $ward',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
          ),
          Text(
            'LGA: $lga',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
          ),
          Text(
            'State: $state',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  election,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppTheme.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Coordinator: $coordinator',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}