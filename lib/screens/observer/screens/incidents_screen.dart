import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../utils/app_theme.dart';
import '../../../models/observer_incident.dart';
import '../../../services/observer_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/form_input.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  List<ObserverIncident> _incidents = [];
  bool _isLoading = true;
  bool _showForm = false;
  File? _selectedImage;
  File? _selectedVideo;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedType = 'Violence';
  final List<String> _incidentTypes = [
    'Violence',
    'Vote Buying',
    'Intimidation',
    'Ballot Box Snatching',
    'Late Arrival of Materials',
    'Security Issue',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    final incidents = await ObserverService.getIncidents();
    setState(() {
      _incidents = incidents;
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

  Future<void> _submitIncident() async {
    if (!_formKey.currentState!.validate()) return;

    final incident = ObserverIncident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      title: _titleController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      date: DateTime.now(),
      status: 'reported',
      observerId: '1',
      pollingUnitId: '1',
    );

    final result = await ObserverService.reportIncident(incident);
    
    if (result['success'] == true) {
      if (_selectedImage != null) {
        await ObserverService.uploadMedia(
          _selectedImage!.path, 
          'image',
          referenceId: result['id'].toString(),
          referenceType: 'incident'
        );
      }
      if (_selectedVideo != null) {
        await ObserverService.uploadMedia(
          _selectedVideo!.path, 
          'video',
          referenceId: result['id'].toString(),
          referenceType: 'incident'
        );
      }
      
      setState(() {
        _incidents.insert(0, incident);
        _showForm = false;
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _selectedImage = null;
        _selectedVideo = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident reported successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
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
                if (_showForm) _buildIncidentForm(),
                Expanded(
                  child: _incidents.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_outlined, size: 64, color: AppTheme.gray400),
                              SizedBox(height: 16),
                              Text(
                                'No incidents reported',
                                style: TextStyle(fontSize: 18, color: AppTheme.gray500),
                              ),
                              Text(
                                'Tap the + button to report one',
                                style: TextStyle(fontSize: 14, color: AppTheme.gray400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _incidents.length,
                          itemBuilder: (context, index) {
                            final incident = _incidents[index];
                            return _buildIncidentCard(incident);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildIncidentForm() {
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
                const Text('Report Incident', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showForm = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Incident Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _incidentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter incident title',
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe the incident in detail',
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter incident location',
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a location' : null,
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
                    onPressed: _submitIncident,
                    text: 'Report',
                    backgroundColor: AppTheme.incidentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentCard(ObserverIncident incident) {
    final statusColors = {
      'reported': AppTheme.danger,
      'investigating': AppTheme.warning,
      'resolved': AppTheme.success,
    };
    final color = statusColors[incident.status] ?? AppTheme.gray500;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      incident.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  incident.status.toUpperCase(),
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
            incident.description,
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
                incident.location,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                '${incident.date.day}/${incident.date.month}/${incident.date.year}',
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