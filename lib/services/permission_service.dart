// services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static Future<bool> requestBiometricPermission() async {
    final status = await Permission.biometric.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<Map<String, bool>> requestAllPermissions() async {
    final permissions = await [
      Permission.biometric,
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ].request();

    return {
      'biometric': permissions[Permission.biometric]?.isGranted ?? false,
      'location': permissions[Permission.location]?.isGranted ?? false,
      'camera': permissions[Permission.camera]?.isGranted ?? false,
      'storage': permissions[Permission.storage]?.isGranted ?? false,
      'notification': permissions[Permission.notification]?.isGranted ?? false,
    };
  }
}