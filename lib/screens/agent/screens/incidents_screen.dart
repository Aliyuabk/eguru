import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_outlined, size: 64, color: AppTheme.gray400),
            SizedBox(height: 16),
            Text(
              'Incidents',
              style: TextStyle(fontSize: 18, color: AppTheme.gray500),
            ),
            Text(
              'Report and track incidents here',
              style: TextStyle(fontSize: 14, color: AppTheme.gray400),
            ),
          ],
        ),
      ),
    );
  }
}