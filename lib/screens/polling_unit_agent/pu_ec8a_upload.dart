import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class PUEC8AUploadScreen extends StatefulWidget {
  const PUEC8AUploadScreen({super.key});

  @override
  State<PUEC8AUploadScreen> createState() => _PUEC8AUploadScreenState();
}

class _PUEC8AUploadScreenState extends State<PUEC8AUploadScreen> {
  XFile? _selectedImage;
  bool _isUploading = false;
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload EC8A'),
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
                            'Take a clear photo of the EC8A form and upload it',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Image Preview or Capture Button
                  GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedImage != null ? AppColors.success : AppColors.gray300,
                          width: 2,
                        ),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                               ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return FutureBuilder<Uint8List>(
                                        future: _selectedImage!.readAsBytes(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            );
                                          }
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.preview,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Tap to change',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera,
                                  size: 48,
                                  color: AppColors.gray400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to take photo',
                                  style: TextStyle(
                                    color: AppColors.gray400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // PU Info
                  Container(
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
                      children: [
                        _buildInfoRow('Polling Unit', 'Kangire P.S'),
                        _buildDivider(),
                        _buildInfoRow('Ward', 'Kangire'),
                        _buildDivider(),
                        _buildInfoRow('LGA', 'Birnin Kudu'),
                        _buildDivider(),
                        _buildInfoRow('Election', '2027 Governorship'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Upload Button
                  CustomButton(
                    text: _selectedImage == null ? 'Select Image First' : 'Upload EC8A',
                    onPressed: _selectedImage != null && !_isUploading
                        ? _uploadImage
                        : null,
                    isLoading: _isUploading,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.gray200,
      height: 1,
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
              'EC8A Uploaded Successfully!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The EC8A form has been uploaded and submitted for verification.',
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

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _uploadImage() {
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