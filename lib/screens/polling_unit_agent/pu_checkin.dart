import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart' as location_pkg;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class PUCheckinScreen extends StatefulWidget {
  const PUCheckinScreen({super.key});

  @override
  State<PUCheckinScreen> createState() => _PUCheckinScreenState();
}

class _PUCheckinScreenState extends State<PUCheckinScreen> {
  bool _isCheckingIn = false;
  bool _isCheckedIn = false;
  bool _hasLocation = false;
  double? _latitude;
  double? _longitude;
  DateTime? _checkinTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        actions: [
          if (_isCheckedIn)
            const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
      body: _isCheckedIn
          ? _buildCheckedInView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Check-in to confirm your presence at the assigned polling unit. This helps track agent attendance.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location Info
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
                        const Divider(color: AppColors.gray200, height: 1),
                        _buildInfoRow('PU Code', 'PU-001'),
                        const Divider(color: AppColors.gray200, height: 1),
                        _buildInfoRow('Ward', 'Kangire'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // GPS Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _hasLocation ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasLocation ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasLocation ? Icons.gps_fixed : Icons.gps_off,
                          color: _hasLocation ? AppColors.success : AppColors.danger,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasLocation ? 'GPS Location Acquired' : 'GPS Location Not Available',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _hasLocation ? AppColors.success : AppColors.danger,
                                ),
                              ),
                              if (_hasLocation)
                                Text(
                                  'Lat: ${_latitude?.toStringAsFixed(6)}  Lng: ${_longitude?.toStringAsFixed(6)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.gray500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!_hasLocation)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _getLocation,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  CustomButton(
                    text: 'Check-in Now',
                    onPressed: _hasLocation && !_isCheckingIn ? _checkin : null,
                    isLoading: _isCheckingIn,
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
          Text(label, style: const TextStyle(color: AppColors.gray600, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCheckedInView() {
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
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Check-in Successful!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully checked in at ${_checkinTime != null ? _formatTime(_checkinTime!) : ''}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_latitude?.toStringAsFixed(6)}  Lng: ${_longitude?.toStringAsFixed(6)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.gray500,
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

  Future<void> _getLocation() async {
    try {
      final location = location_pkg.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      location_pkg.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == location_pkg.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != location_pkg.PermissionStatus.granted) return;
      }

      location_pkg.LocationData currentLocation = await location.getLocation();
      
      setState(() {
        _latitude = currentLocation.latitude;
        _longitude = currentLocation.longitude;
        _hasLocation = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _checkin() {
    setState(() {
      _isCheckingIn = true;
    });

    // Simulate check-in
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCheckingIn = false;
        _isCheckedIn = true;
        _checkinTime = DateTime.now();
      });
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}