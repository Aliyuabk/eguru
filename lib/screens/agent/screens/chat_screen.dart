import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_outlined, size: 64, color: AppTheme.gray400),
            SizedBox(height: 16),
            Text(
              'Chat',
              style: TextStyle(fontSize: 18, color: AppTheme.gray500),
            ),
            Text(
              'Communicate with your coordinator',
              style: TextStyle(fontSize: 14, color: AppTheme.gray400),
            ),
          ],
        ),
      ),
    );
  }
}