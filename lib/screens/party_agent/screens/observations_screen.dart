import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../utils/app_theme.dart';
import '../../../models/observation.dart';
import '../../../services/party_agent_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/form_input.dart';

class ObservationsScreen extends StatefulWidget {
  const ObservationsScreen({super.key});

  @override
  State<ObservationsScreen> createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends State<ObservationsScreen> {
  List<Observation> _observations = [];
  bool _isLoading = true;
  bool _showForm = false;
  File? _selectedImage;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPollingUnitId = '1';

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    setState(() => _isLoading = true);
    final observations = await PartyAgentService.getObservations();
    setState(() {
      _observations = observations;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _submitObservation() async {
    if (!_formKey.currentState!.validate()) return;

    final observation = Observation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      date: DateTime.now(),
      status: 'submitted',
      pollingUnitId: _selectedPollingUnitId,
    );

    final result = await PartyAgentService.submitObservation(observation);
    
    if (result['success'] == true) {
      if (_selectedImage != null) {
        await PartyAgentService.uploadEvidence(_selectedImage!.path, result['id'].toString());
      }
      
      setState(() {
        _observations.insert(0, observation);
        _showForm = false;
        _titleController.clear();
        _descriptionController.clear();
        _selectedImage = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Observation submitted successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit observation'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_showForm) _buildObservationForm(),
                Expanded(
                  child: _observations.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined, size: 64, color: AppTheme.gray400),
                              SizedBox(height: 16),
                              Text('No observations yet', style: TextStyle(fontSize: 18, color: AppTheme.gray500)),
                              Text('Tap the + button to add one', style: TextStyle(fontSize: 14, color: AppTheme.gray400)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _observations.length,
                          itemBuilder: (context, index) => _buildObservationCard(_observations[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildObservationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Observation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showForm = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter observation title',
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter observation details',
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _pickImage,
                    text: _selectedImage != null ? 'Photo Selected' : 'Take Photo',
                    icon: Icons.photo_camera,
                    backgroundColor: AppTheme.secondary,
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.danger),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => setState(() => _showForm = false),
                    text: 'Cancel',
                    backgroundColor: AppTheme.gray300,
                    textColor: AppTheme.gray700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: _submitObservation,
                    text: 'Submit',
                    backgroundColor: AppTheme.observationColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationCard(Observation observation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(
                  observation.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: observation.status == 'submitted'
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  observation.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: observation.status == 'submitted' ? AppTheme.success : AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(observation.description, style: TextStyle(fontSize: 14, color: AppTheme.gray600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.gray400),
              const SizedBox(width: 4),
              Text(_formatDate(observation.date), style: TextStyle(fontSize: 12, color: AppTheme.gray400)),
              if (observation.imageUrl != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.photo, size: 14, color: AppTheme.gray400),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}