import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class PUChecklistScreen extends StatefulWidget {
  const PUChecklistScreen({super.key});

  @override
  State<PUChecklistScreen> createState() => _PUChecklistScreenState();
}

class _PUChecklistScreenState extends State<PUChecklistScreen> {
  final Map<String, bool> _checklistItems = {
    'materialsArrived': false,
    'pollOpened': false,
    'accreditationStarted': false,
    'votingStarted': false,
    'countingStarted': false,
    'pollClosed': false,
  };
  
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Checklist'),
        actions: [
          if (_isSubmitted)
            const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
      body: _isSubmitted
          ? _buildSubmittedView()
          : _buildChecklistForm(),
    );
  }

  Widget _buildChecklistForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Election Checklist',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mark all activities as they are completed during the election process',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Checklist Items
          ..._checklistItems.keys.map((key) {
            return _buildChecklistItem(
              key,
              _getItemLabel(key),
              _getItemIcon(key),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Submit Button
          CustomButton(
            text: 'Submit Checklist',
            onPressed: _isSubmitting ? null : _submitChecklist,
            isLoading: _isSubmitting,
          ),
          
          const SizedBox(height: 8),
          
          // Progress
          LinearProgressIndicator(
            value: _getProgress(),
            backgroundColor: AppColors.gray200,
            color: AppColors.primary,
          ),
          const SizedBox(height: 4),
          Text(
            '${(_getProgress() * 100).round()}% completed',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String key, String label, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _checklistItems[key]!
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.gray200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _checklistItems[key]! ? Icons.check : icon,
            color: _checklistItems[key]! ? AppColors.success : AppColors.gray400,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            decoration: _checklistItems[key]!
                ? TextDecoration.lineThrough
                : null,
            color: _checklistItems[key]!
                ? AppColors.gray500
                : AppColors.gray800,
          ),
        ),
        trailing: Switch(
          value: _checklistItems[key]!,
          onChanged: (value) {
            setState(() {
              _checklistItems[key] = value;
            });
          },
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSubmittedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Checklist Submitted!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your election checklist has been successfully submitted.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Back to Dashboard',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getItemLabel(String key) {
    switch (key) {
      case 'materialsArrived':
        return 'Election Materials Arrived';
      case 'pollOpened':
        return 'Poll Opened';
      case 'accreditationStarted':
        return 'Accreditation Started';
      case 'votingStarted':
        return 'Voting Started';
      case 'countingStarted':
        return 'Counting Started';
      case 'pollClosed':
        return 'Poll Closed';
      default:
        return '';
    }
  }

  IconData _getItemIcon(String key) {
    switch (key) {
      case 'materialsArrived':
        return Icons.inventory;
      case 'pollOpened':
        return Icons.open_in_new;
      case 'accreditationStarted':
        return Icons.assignment_ind;
      case 'votingStarted':
        return Icons.how_to_vote;
      case 'countingStarted':
        return Icons.calculate;
      case 'pollClosed':
        return Icons.close;
      default:
        return Icons.check;
    }
  }

  double _getProgress() {
    final completed = _checklistItems.values.where((v) => v).length;
    return completed / _checklistItems.length;
  }

  void _submitChecklist() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    });
  }
}