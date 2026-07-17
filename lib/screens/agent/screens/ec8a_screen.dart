import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../utils/app_theme.dart';
import '../../../models/ec8a_result.dart';
import '../../../services/pu_agent_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/form_input.dart';

class EC8AScreen extends StatefulWidget {
  const EC8AScreen({super.key});

  @override
  State<EC8AScreen> createState() => _EC8AScreenState();
}

class _EC8AScreenState extends State<EC8AScreen> {
  final _formKey = GlobalKey<FormState>();
  final _puCodeController = TextEditingController();
  final _puNameController = TextEditingController();
  final _registeredVotersController = TextEditingController();
  final _accreditedVotersController = TextEditingController();
  final _validVotesController = TextEditingController();
  final _rejectedVotesController = TextEditingController();
  final _remarksController = TextEditingController();
  
  List<Map<String, dynamic>> _partyVotes = [];
  bool _isLoading = false;
  File? _resultPhoto;
  
  final List<String> _parties = ['APC', 'PDP', 'LP', 'NNPP'];
  final List<String> _electionTypes = ['Governorship', 'Presidential', 'Senatorial', 'House of Reps'];

  @override
  void initState() {
    super.initState();
    _initializePartyVotes();
    _loadPUDetails();
  }

  void _initializePartyVotes() {
    _partyVotes = _parties.map((party) => {
      'name': party,
      'votes': '',
    }).toList();
  }

  Future<void> _loadPUDetails() async {
    try {
      final pu = await PUAgentService.getAssignedPollingUnit();
      if (pu != null) {
        setState(() {
          _puCodeController.text = pu.code;
          _puNameController.text = pu.name;
        });
      }
    } catch (e) {
      print('Error loading PU details: $e');
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _resultPhoto = File(image.path));
    }
  }

  Future<void> _submitResult() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if all party votes are entered
    for (var party in _partyVotes) {
      if (party['votes'] == null || party['votes'].toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter votes for all parties'),
            backgroundColor: AppTheme.danger,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final result = EC8AResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tenantId: '14',
        electionId: '11',
        puId: '1',
        wardId: '1',
        lgaId: '1',
        stateId: '1',
        agentId: '1',
        assignmentId: '1',
        puCode: _puCodeController.text,
        puName: _puNameController.text,
        registeredVoters: int.parse(_registeredVotersController.text),
        accreditedVoters: int.parse(_accreditedVotersController.text),
        ballotPapersIssued: int.parse(_registeredVotersController.text),
        unusedBallots: 0,
        spoiledBallots: 0,
        rejectedVotes: int.parse(_rejectedVotesController.text),
        validVotes: int.parse(_validVotesController.text),
        totalVotesCast: int.parse(_validVotesController.text) + int.parse(_rejectedVotesController.text),
        partyVotes: _partyVotes.map((p) => {
          'party': p['name'],
          'votes': int.parse(p['votes'].toString()),
        }).toList(),
        photoUrl: null,
        remarks: _remarksController.text,
        status: 'pending',
        isOfflineSync: true,
        createdAt: DateTime.now(),
      );

      final response = await PUAgentService.submitEC8A(result);
      
      if (response['success'] == true) {
        // Upload photo if available
        if (_resultPhoto != null) {
          await PUAgentService.uploadPhoto(_resultPhoto!.path, 'ec8a');
        }
        
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception(response['message'] ?? 'Submission failed');
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'EC8A Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your EC8A result has been submitted successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.gray600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              text: 'Done',
              backgroundColor: AppTheme.success,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EC8A Entry'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Polling Unit Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FormInput(
                        controller: _puCodeController,
                        label: 'Polling Unit Code',
                        hint: 'Enter PU Code',
                        enabled: false,
                      ),
                      const SizedBox(height: 12),
                      FormInput(
                        controller: _puNameController,
                        label: 'Polling Unit Name',
                        hint: 'Enter PU Name',
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Voter Numbers
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FormInput(
                        controller: _registeredVotersController,
                        label: 'Registered Voters',
                        hint: 'Enter number of registered voters',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (int.tryParse(value!) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      FormInput(
                        controller: _accreditedVotersController,
                        label: 'Accredited Voters',
                        hint: 'Enter number of accredited voters',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (int.tryParse(value!) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Party Votes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Party Votes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._partyVotes.map((party) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  party['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Votes',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final index = _partyVotes.indexOf(party);
                                    setState(() {
                                      _partyVotes[index]['votes'] = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Required';
                                    if (int.tryParse(value!) == null) return 'Enter a valid number';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Vote Totals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FormInput(
                          controller: _validVotesController,
                          label: 'Valid Votes',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (int.tryParse(value!) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormInput(
                          controller: _rejectedVotesController,
                          label: 'Rejected Votes',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (int.tryParse(value!) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Remarks
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FormInput(
                    controller: _remarksController,
                    label: 'Remarks',
                    hint: 'Enter any remarks or observations',
                    maxLines: 3,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Photo Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload EC8A Photo (Required)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        onPressed: _takePhoto,
                        text: _resultPhoto != null ? 'Photo Taken' : 'Take Photo',
                        icon: Icons.photo_camera,
                        backgroundColor: _resultPhoto != null ? AppTheme.success : AppTheme.secondary,
                      ),
                      if (_resultPhoto != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_resultPhoto!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _resultPhoto = null),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              CustomButton(
                onPressed: _submitResult,
                isLoading: _isLoading,
                text: 'Submit EC8A',
                icon: Icons.send,
                backgroundColor: AppTheme.observationColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}