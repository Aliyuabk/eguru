import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
// import 'package:audio_recorder/audio_recorder.dart';

class PUMediaUploadScreen extends StatefulWidget {
  const PUMediaUploadScreen({super.key});

  @override
  State<PUMediaUploadScreen> createState() => _PUMediaUploadScreenState();
}

class _PUMediaUploadScreenState extends State<PUMediaUploadScreen> {
  final List<XFile> _images = [];
  final List<XFile> _videos = [];
  final List<XFile> _documents = [];
  bool _isUploading = false;
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Upload'),
        actions: [
          if (_isSubmitted)
            const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
      body: _isSubmitted
          ? _buildSubmittedView()
          : SingleChildScrollView(
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
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upload photos, videos, and documents as evidence',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Photos
                  _buildMediaSection(
                    title: 'Photos',
                    icon: Icons.photo_camera,
                    count: _images.length,
                    onTap: _pickImages,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Videos
                  _buildMediaSection(
                    title: 'Videos',
                    icon: Icons.videocam,
                    count: _videos.length,
                    onTap: _pickVideos,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Documents
                  _buildMediaSection(
                    title: 'Documents',
                    icon: Icons.folder,
                    count: _documents.length,
                    onTap: _pickDocuments,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preview
                  if (_images.isNotEmpty || _videos.isNotEmpty || _documents.isNotEmpty)
                    _buildMediaPreview(),
                  
                  const SizedBox(height: 24),
                  
                  // Upload Button
                  CustomButton(
                    text: 'Upload All Media',
                    onPressed: (_images.isNotEmpty || _videos.isNotEmpty || _documents.isNotEmpty) && !_isUploading
                        ? _uploadMedia
                        : null,
                    isLoading: _isUploading,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMediaSection({
    required String title,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$count file${count != 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.gray400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Files',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_images.isNotEmpty) ...[
            const Text('Photos:', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
            Wrap(
              spacing: 4,
              children: _images.map((image) {
                return Chip(
                  label: Text(
                    image.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                  onDeleted: () {
                    setState(() {
                      _images.remove(image);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          if (_videos.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Videos:', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
            Wrap(
              spacing: 4,
              children: _videos.map((video) {
                return Chip(
                  label: Text(
                    video.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                  onDeleted: () {
                    setState(() {
                      _videos.remove(video);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          if (_documents.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Documents:', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
            Wrap(
              spacing: 4,
              children: _documents.map((doc) {
                return Chip(
                  label: Text(
                    doc.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                  onDeleted: () {
                    setState(() {
                      _documents.remove(doc);
                    });
                  },
                );
              }).toList(),
            ),
          ],
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
              'Media Uploaded!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'All selected media files have been uploaded successfully.',
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

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
      });
    }
  }

  Future<void> _pickVideos() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (video != null) {
      setState(() {
        _videos.add(video);
      });
    }
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          _documents.add(XFile(file.path!));
        }
      });
    }
  }

  void _uploadMedia() {
    setState(() {
      _isUploading = true;
    });

    // Simulate upload
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isUploading = false;
        _isSubmitted = true;
      });
    });
  }
}