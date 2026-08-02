import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _inAppNotifications = true;
  bool _electionUpdates = true;
  bool _incidentAlerts = true;
  bool _chatMessages = true;
  bool _broadcastMessages = true;
  bool _resultUpdates = true;
  bool _systemUpdates = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            _buildSectionHeader('General Settings'),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on your device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
              icon: Icons.notifications_active,
            ),
            _buildSwitchTile(
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              icon: Icons.email,
            ),
            _buildSwitchTile(
              title: 'In-App Notifications',
              subtitle: 'Show notifications within the app',
              value: _inAppNotifications,
              onChanged: (value) {
                setState(() {
                  _inAppNotifications = value;
                });
              },
              icon: Icons.notifications,
            ),
            
            const SizedBox(height: 24),
            
            // Notification Types
            _buildSectionHeader('Notification Types'),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Election Updates',
              subtitle: 'Get updates about elections and voting',
              value: _electionUpdates,
              onChanged: (value) {
                setState(() {
                  _electionUpdates = value;
                });
              },
              icon: Icons.how_to_vote,
            ),
            _buildSwitchTile(
              title: 'Incident Alerts',
              subtitle: 'Get alerts about reported incidents',
              value: _incidentAlerts,
              onChanged: (value) {
                setState(() {
                  _incidentAlerts = value;
                });
              },
              icon: Icons.warning,
            ),
            _buildSwitchTile(
              title: 'Chat Messages',
              subtitle: 'Get notifications for new chat messages',
              value: _chatMessages,
              onChanged: (value) {
                setState(() {
                  _chatMessages = value;
                });
              },
              icon: Icons.chat,
            ),
            _buildSwitchTile(
              title: 'Broadcast Messages',
              subtitle: 'Get notifications for broadcast messages',
              value: _broadcastMessages,
              onChanged: (value) {
                setState(() {
                  _broadcastMessages = value;
                });
              },
              icon: Icons.campaign,
            ),
            _buildSwitchTile(
              title: 'Result Updates',
              subtitle: 'Get notifications when results are submitted',
              value: _resultUpdates,
              onChanged: (value) {
                setState(() {
                  _resultUpdates = value;
                });
              },
              icon: Icons.assessment,
            ),
            _buildSwitchTile(
              title: 'System Updates',
              subtitle: 'Get notifications about system updates',
              value: _systemUpdates,
              onChanged: (value) {
                setState(() {
                  _systemUpdates = value;
                });
              },
              icon: Icons.settings,
            ),
            
            const SizedBox(height: 24),
            
            // Preferences
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Sound',
              subtitle: 'Play sound for notifications',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              icon: Icons.volume_up,
            ),
            _buildSwitchTile(
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              icon: Icons.vibration,
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Settings',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gray800,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  void _saveSettings() {
    // Here you would save the settings to SharedPreferences or API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved successfully!',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}