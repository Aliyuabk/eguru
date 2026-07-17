import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_theme.dart';
import '../../../models/agent_checkin.dart';
import '../../../services/pu_agent_service.dart';
import '../../../widgets/custom_button.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isLoading = false;
  bool _isCheckedIn = false;
  Position? _currentPosition;
  File? _photo;
  String _checkinType = 'arrival';
  String _status = 'Not Checked In';
  DateTime? _checkInTime;
  String? _errorMessage;

  final List<String> _checkinTypes = [
    'arrival',
    'departure',
    'material_received',
    'accreditation_started',
    'voting_started',
    'voting_ended',
    'counting_started',
    'counting_ended',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadCheckinStatus();
  }

  Future<void> _loadCheckinStatus() async {
    try {
      final checkins = await PUAgentService.getCheckins();
      final today = DateTime.now();
      final todayCheckin = checkins.where((c) => 
        c.createdAt.year == today.year &&
        c.createdAt.month == today.month &&
        c.createdAt.day == today.day
      ).firstOrNull;
      
      if (todayCheckin != null) {
        setState(() {
          _isCheckedIn = true;
          _status = 'Checked In';
          _checkInTime = todayCheckin.createdAt;
          _checkinType = todayCheckin.checkinType;
        });
      }
    } catch (e) {
      print('Error loading checkin status: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Please enable GPS/Location services';
        });
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied';
        });
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _photo = File(image.path));
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _checkIn() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable GPS to check in'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final checkin = AgentCheckin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tenantId: '14',
        electionId: '11',
        agentId: '1',
        assignmentId: '1',
        puId: '1',
        checkinType: _checkinType,
        gpsLat: _currentPosition!.latitude,
        gpsLng: _currentPosition!.longitude,
        gpsAccuracy: _currentPosition!.accuracy,
        photoUrl: null,
        deviceId: 'device_001',
        deviceBattery: 85,
        networkType: '4g',
        isOfflineSync: true,
        createdAt: DateTime.now(),
      );

      final result = await PUAgentService.checkIn(checkin);
      
      if (result['success'] == true) {
        setState(() {
          _isCheckedIn = true;
          _status = 'Checked In';
          _checkInTime = DateTime.now();
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in successful!'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Check-in failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCheckinType(String type) {
    return type.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                boxShadow: AppTheme.shadow,
              ),
              child: Column(
                children: [
                  Icon(
                    _isCheckedIn ? Icons.check_circle : Icons.circle_outlined,
                    size: 64,
                    color: _isCheckedIn ? AppTheme.success : AppTheme.gray400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isCheckedIn ? AppTheme.success : AppTheme.gray500,
                    ),
                  ),
                  if (_checkInTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Checked in at: ${_formatTime(_checkInTime!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray500,
                      ),
                    ),
                    Text(
                      'Type: ${_formatCheckinType(_checkinType)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Check-in Type Dropdown
            DropdownButtonFormField<String>(
              value: _checkinType,
              decoration: InputDecoration(
                labelText: 'Check-in Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _checkinTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_formatCheckinType(type)),
                );
              }).toList(),
              onChanged: _isCheckedIn ? null : (value) {
                setState(() => _checkinType = value!);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Location Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                boxShadow: AppTheme.shadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Your Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_currentPosition != null) ...[
                    Text(
                      'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ] else ...[
                    const Text(
                      'Fetching location...',
                      style: TextStyle(fontSize: 14, color: AppTheme.gray500),
                    ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.danger),
                      ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: _getCurrentLocation,
                          text: 'Refresh Location',
                          backgroundColor: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Photo Upload
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                boxShadow: AppTheme.shadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Take Photo (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: _takePhoto,
                          text: _photo != null ? 'Photo Taken' : 'Take Photo',
                          icon: Icons.photo_camera,
                          backgroundColor: AppTheme.secondary,
                        ),
                      ),
                      if (_photo != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.danger),
                          onPressed: () => setState(() => _photo = null),
                        ),
                      ],
                    ],
                  ),
                  if (_photo != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_photo!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Check-in Button
            CustomButton(
              onPressed: _isCheckedIn ? null : _checkIn,
              isLoading: _isLoading,
              text: _isCheckedIn ? 'Checked In' : 'Check In',
              backgroundColor: _isCheckedIn ? AppTheme.success : AppTheme.primary,
              icon: _isCheckedIn ? Icons.check : Icons.login,
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppTheme.danger,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}