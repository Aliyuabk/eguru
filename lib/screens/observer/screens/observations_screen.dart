import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../utils/app_theme.dart';
import '../../../models/observer_observation.dart';
import '../../../services/observer_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/form_input.dart';

class ObservationsScreen extends StatefulWidget {
  const ObservationsScreen({super.key});

  @override
  State<ObservationsScreen> createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends State<ObservationsScreen> {
  List<ObserverObservation> _observations = [];
  bool _isLoading = true;
  bool _showForm = false;
  File? _selectedImage;
  File? _selectedVideo;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  String _selectedCategory = 'Poll Opening';
  final List<String> _categories = [
    'Poll Opening',
    'Accreditation Process',
    'Voting Process',
    'Counting Process',
    'Poll Closing',
    'General Observation',
  ];

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    setState(() => _isLoading = true);
    final observations = await ObserverService.getObservations();
    setState(() {
      _observations = observations;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) setState(() => _selectedVideo = File(video.path));
  }

  Future<void> _submitObservation() async {
    if (!_formKey.currentState!.validate()) return;

    final observation = ObserverObservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      location: _locationController.text,
      date: DateTime.now(),
      time: _timeController.text,
      status: 'submitted',
      observerId: '1',
      pollingUnitId: '1',
    );

    final result = await ObserverService.submitObservation(observation);
    
    if (result['success'] == true) {
      if (_selectedImage != null) {
        await ObserverService.uploadMedia(
          _selectedImage!.path, 
          'image',
          referenceId: result['id'].toString(),
          referenceType: 'observation'
        );
      }
      if (_selectedVideo != null) {
        await ObserverService.uploadMedia(
          _selectedVideo!.path, 
          'video',
          referenceId: result['id'].toString(),
          referenceType: 'observation'
        );
      }
      
      setState(() {
        _observations.insert(0, observation);
        _showForm = false;
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _timeController.clear();
        _selectedImage = null;
        _selectedVideo = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Observation submitted successfully!'),
          backgroundColor: AppTheme.success,
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
                              Icon(Icons.remove_red_eye_outlined, size: 64, color: AppTheme.gray400),
                              SizedBox(height: 16),
                              Text(
                                'No observations yet',
                                style: TextStyle(fontSize: 18, color: AppTheme.gray500),
                              ),
                              Text(
                                'Tap the + button to add one',
                                style: TextStyle(fontSize: 14, color: AppTheme.gray400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _observations.length,
                          itemBuilder: (context, index) {
                            final observation = _observations[index];
                            return _buildObservationCard(observation);
                          },
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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your observation',
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FormInput(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Enter location',
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter a location' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FormInput(
                    controller: _timeController,
                    label: 'Time',
                    hint: 'HH:MM',
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter time' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _pickImage,
                    text: _selectedImage != null ? 'Photo 📷' : 'Take Photo',
                    icon: Icons.photo_camera,
                    backgroundColor: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    onPressed: _pickVideo,
                    text: _selectedVideo != null ? 'Video 🎥' : 'Record Video',
                    icon: Icons.videocam,
                    backgroundColor: AppTheme.info,
                  ),
                ),
              ],
            ),
            if (_selectedImage != null || _selectedVideo != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (_selectedImage != null)
                    Chip(
                      label: const Text('Image'),
                      onDeleted: () => setState(() => _selectedImage = null),
                    ),
                  if (_selectedVideo != null)
                    Chip(
                      label: const Text('Video'),
                      onDeleted: () => setState(() => _selectedVideo = null),
                    ),
                ],
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

  Widget _buildObservationCard(ObserverObservation observation) {
    final statusColors = {
      'draft': AppTheme.warning,
      'submitted': AppTheme.info,
      'approved': AppTheme.success,
      'rejected': AppTheme.danger,
    };
    final color = statusColors[observation.status] ?? AppTheme.gray500;

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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  observation.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            observation.category,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            observation.description,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: AppTheme.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                observation.location,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                observation.time,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}