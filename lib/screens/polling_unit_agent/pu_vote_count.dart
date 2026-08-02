import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class PUVoteCountScreen extends StatefulWidget {
  const PUVoteCountScreen({super.key});

  @override
  State<PUVoteCountScreen> createState() => _PUVoteCountScreenState();
}

class _PUVoteCountScreenState extends State<PUVoteCountScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _partyControllers = {};
  final List<Map<String, dynamic>> _parties = [
    {'name': 'APC', 'color': Colors.green},
    {'name': 'PDP', 'color': Colors.red},
    {'name': 'LP', 'color': Colors.blue},
    {'name': 'NNPP', 'color': Colors.orange},
    {'name': 'Other', 'color': Colors.grey},
  ];
  
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var party in _parties) {
      _partyControllers[party['name']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _partyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Count'),
        actions: [
          if (_isSubmitted)
            const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
      body: _isSubmitted
          ? _buildSubmittedView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Enter the vote count for each party at this polling unit',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Vote Count Fields
                    ..._parties.map((party) {
                      return _buildPartyVoteField(party);
                    }),
                    
                    const SizedBox(height: 16),
                    
                    // Total Votes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Votes:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _calculateTotalVotes().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    CustomButton(
                      text: 'Submit Vote Count',
                      onPressed: _isSubmitting ? null : _submitVoteCount,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPartyVoteField(Map<String, dynamic> party) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(
              color: party['color'],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              party['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: _partyControllers[party['name']],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
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
              'Vote Count Submitted!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Vote count records have been successfully submitted.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _parties.map((party) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          party['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _partyControllers[party['name']]?.text ?? '0',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
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

  int _calculateTotalVotes() {
    int total = 0;
    for (var controller in _partyControllers.values) {
      total += int.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  void _submitVoteCount() {
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