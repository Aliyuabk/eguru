// services/permission_service.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // ============================================================
  // INDIVIDUAL PERMISSION REQUESTS
  // ============================================================

  // FIXED: Removed biometric reference
  static Future<bool> requestLocationPermission({
    required BuildContext context,
  }) async {
    return await requestPermissionWithDialog(
      context: context,
      permission: Permission.location,
      permissionName: 'Location',
      message: 'This app uses your location to verify your presence at polling units and provide accurate reporting.',
    );
  }

  static Future<bool> requestCameraPermission({
    required BuildContext context,
  }) async {
    return await requestPermissionWithDialog(
      context: context,
      permission: Permission.camera,
      permissionName: 'Camera',
      message: 'This app uses your camera to capture photos of election materials, results, and incidents.',
    );
  }

  static Future<bool> requestStoragePermission({
    required BuildContext context,
  }) async {
    return await requestPermissionWithDialog(
      context: context,
      permission: Permission.storage,
      permissionName: 'Storage',
      message: 'This app needs storage access to save photos, videos, and documents.',
    );
  }

  static Future<bool> requestNotificationPermission({
    required BuildContext context,
  }) async {
    return await requestPermissionWithDialog(
      context: context,
      permission: Permission.notification,
      permissionName: 'Notifications',
      message: 'This app sends notifications for important updates, alerts, and messages.',
    );
  }

  static Future<bool> requestMicrophonePermission({
    required BuildContext context,
  }) async {
    return await requestPermissionWithDialog(
      context: context,
      permission: Permission.microphone,
      permissionName: 'Microphone',
      message: 'This app uses your microphone for voice recording and audio features.',
    );
  }

  // ============================================================
  // BULK PERMISSION REQUESTS (FIXED)
  // ============================================================

  static Future<Map<String, bool>> requestEssentialPermissions() async {
    try {
      final permissions = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        Permission.notification,
      ].request();

      return {
        'location': permissions[Permission.location]?.isGranted ?? false,
        'camera': permissions[Permission.camera]?.isGranted ?? false,
        'storage': permissions[Permission.storage]?.isGranted ?? false,
        'notification': permissions[Permission.notification]?.isGranted ?? false,
      };
    } catch (e) {
      print('🔴 Essential permissions error: $e');
      return {
        'location': false,
        'camera': false,
        'storage': false,
        'notification': false,
      };
    }
  }

  static Future<Map<String, bool>> requestAllPermissions() async {
    try {
      final permissions = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        Permission.notification,
        Permission.microphone,
        Permission.phone,
        Permission.contacts,
        Permission.calendar,
        Permission.sms,
      ].request();

      return {
        'location': permissions[Permission.location]?.isGranted ?? false,
        'camera': permissions[Permission.camera]?.isGranted ?? false,
        'storage': permissions[Permission.storage]?.isGranted ?? false,
        'notification': permissions[Permission.notification]?.isGranted ?? false,
        'microphone': permissions[Permission.microphone]?.isGranted ?? false,
        'phone': permissions[Permission.phone]?.isGranted ?? false,
        'contacts': permissions[Permission.contacts]?.isGranted ?? false,
        'calendar': permissions[Permission.calendar]?.isGranted ?? false,
        'sms': permissions[Permission.sms]?.isGranted ?? false,
      };
    } catch (e) {
      print('🔴 All permissions error: $e');
      return {
        'location': false,
        'camera': false,
        'storage': false,
        'notification': false,
        'microphone': false,
        'phone': false,
        'contacts': false,
        'calendar': false,
        'sms': false,
      };
    }
  }

  // ============================================================
  // PERMISSION STATUS CHECKERS (FIXED)
  // ============================================================

  static Future<bool> isLocationGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static Future<bool> isStorageGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  static Future<bool> isNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<bool> isMicrophoneGranted() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  // ============================================================
  // PERMISSION UI HELPERS
  // ============================================================

  static Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    String positiveButtonText = 'Grant Permission',
    String negativeButtonText = 'Skip',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(negativeButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(positiveButtonText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showPermissionDeniedDialog({
    required BuildContext context,
    required String permissionName,
    VoidCallback? onOpenSettings,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Denied'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have denied the $permissionName permission. '
              'This feature requires $permissionName access to function properly.',
            ),
            const SizedBox(height: 8),
            Text(
              'Please grant permission in your device settings.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOpenSettings != null) {
                onOpenSettings();
              } else {
                openAppSettings();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REQUEST PERMISSION WITH UI
  // ============================================================

  static Future<bool> requestPermissionWithDialog({
    required BuildContext context,
    required Permission permission,
    required String permissionName,
    required String message,
  }) async {
    // Check if already granted
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    // Show explanation dialog if needed
    if (status.isDenied) {
      final shouldRequest = await showPermissionDialog(
        context: context,
        title: '$permissionName Permission Required',
        message: message,
      );

      if (!shouldRequest) {
        return false;
      }
    }

    // Request permission
    final result = await permission.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      await showPermissionDeniedDialog(
        context: context,
        permissionName: permissionName,
      );
      return false;
    } else {
      return false;
    }
  }

  // ============================================================
  // INITIALIZE PERMISSIONS ON APP START
  // ============================================================

  static Future<Map<String, bool>> initializePermissions() async {
    try {
      final statuses = await requestEssentialPermissions();
      
      print('🟢 Permission Status:');
      statuses.forEach((key, value) {
        print('   $key: ${value ? "Granted" : "Denied"}');
      });
      
      return statuses;
    } catch (e) {
      print('🔴 Initialize permissions error: $e');
      return {};
    }
  }
}