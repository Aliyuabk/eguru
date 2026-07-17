import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../services/pu_agent_service.dart';
import '../../../widgets/custom_button.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<Map<String, dynamic>> _checklistItems = [
    {'id': 'materials', 'label': 'Election Materials Arrived', 'completed': false},
    {'id': 'poll_opened', 'label': 'Poll Opened', 'completed': false},
    {'id': 'accreditation', 'label': 'Accreditation Started', 'completed': false},
    {'id': 'voting', 'label': 'Voting Started', 'completed': false},
    {'id': 'counting', 'label': 'Counting Started', 'completed': false},
    {'id': 'poll_closed', 'label': 'Poll Closed', 'completed': false},
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    try {
      final result = await PUAgentService.getChecklist();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          for (var item in _checklistItems) {
            final id = item['id'] as String;
            item['completed'] = data[id] ?? false;
          }
        });
      }
    } catch (e) {
      print('Error loading checklist: $e');
    }
  }

  Future<void> _submitChecklist() async {
    setState(() => _isLoading = true);
    
    try {
      // Create a properly typed map
      final Map<String, dynamic> data = {};
      for (var item in _checklistItems) {
        data[item['id'] as String] = item['completed'];
      }
      
      final result = await PUAgentService.submitChecklist(data);
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checklist submitted successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Submission failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Checklist'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                boxShadow: AppTheme.shadow,
              ),
              child: Column(
                children: _checklistItems.map((item) {
                  return CheckboxListTile(
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontWeight: (item['completed'] as bool) ? FontWeight.bold : FontWeight.normal,
                        color: (item['completed'] as bool) ? AppTheme.success : AppTheme.gray700,
                      ),
                    ),
                    value: item['completed'] as bool,
                    onChanged: (value) {
                      setState(() {
                        item['completed'] = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primary,
                    tileColor: (item['completed'] as bool) 
                        ? AppTheme.success.withOpacity(0.05) 
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Complete all checklist items as they happen during the election process.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            CustomButton(
              onPressed: _submitChecklist,
              isLoading: _isLoading,
              text: 'Submit Checklist',
              icon: Icons.send,
              backgroundColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}