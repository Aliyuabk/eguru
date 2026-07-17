import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../utils/app_theme.dart';
import '../../../models/community_report.dart';
import '../../../services/volunteer_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/form_input.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<CommunityReport> _reports = [];
  bool _isLoading = true;
  bool _showForm = false;
  File? _selectedImage;
  File? _selectedVideo;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Campaign Activity';
  final List<String> _categories = [
    'Campaign Activity',
    'Community Feedback',
    'Voter Education',
    'Election Awareness',
    'Security Issue',
    'General Report',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await VolunteerService.getReports();
    setState(() {
      _reports = reports;
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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final report = CommunityReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      location: _locationController.text,
      date: DateTime.now(),
      status: 'submitted',
      volunteerId: '1',
    );

    final result = await VolunteerService.submitReport(report);
    
    if (result['success'] == true) {
      if (_selectedImage != null) {
        await VolunteerService.uploadMedia(_selectedImage!.path, 'image');
      }
      if (_selectedVideo != null) {
        await VolunteerService.uploadMedia(_selectedVideo!.path, 'video');
      }
      
      setState(() {
        _reports.insert(0, report);
        _showForm = false;
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _selectedImage = null;
        _selectedVideo = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
                if (_showForm) _buildReportForm(),
                Expanded(
                  child: _reports.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.report_outlined, size: 64, color: AppTheme.gray400),
                              SizedBox(height: 16),
                              Text(
                                'No reports yet',
                                style: TextStyle(fontSize: 18, color: AppTheme.gray500),
                              ),
                              Text(
                                'Tap the + button to create one',
                                style: TextStyle(fontSize: 14, color: AppTheme.gray400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return _buildReportCard(report);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildReportForm() {
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
                const Text('New Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              hint: 'Enter report title',
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
              hint: 'Describe your report',
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 12),
            FormInput(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter location',
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
                    onPressed: _submitReport,
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

  Widget _buildReportCard(CommunityReport report) {
    final statusColors = {
      'draft': AppTheme.warning,
      'submitted': AppTheme.info,
      'approved': AppTheme.success,
      'rejected': AppTheme.danger,
    };
    final color = statusColors[report.status] ?? AppTheme.gray500;

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
                  report.title,
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
                  report.status.toUpperCase(),
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
            report.description,
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
                Icons.category,
                size: 14,
                color: AppTheme.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                report.category,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                size: 14,
                color: AppTheme.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                report.location,
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
                _formatDate(report.date),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}