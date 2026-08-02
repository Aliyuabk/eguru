import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';
  
  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇬🇧',
      'isRTL': false,
    },
    {
      'code': 'ha',
      'name': 'Hausa',
      'nativeName': 'Hausa',
      'flag': '🇳🇬',
      'isRTL': false,
    },
    {
      'code': 'yo',
      'name': 'Yoruba',
      'nativeName': 'Yorùbá',
      'flag': '🇳🇬',
      'isRTL': false,
    },
    {
      'code': 'ig',
      'name': 'Igbo',
      'nativeName': 'Igbo',
      'flag': '🇳🇬',
      'isRTL': false,
    },
    {
      'code': 'fr',
      'name': 'French',
      'nativeName': 'Français',
      'flag': '🇫🇷',
      'isRTL': false,
    },
    {
      'code': 'ar',
      'name': 'Arabic',
      'nativeName': 'العربية',
      'flag': '🇸🇦',
      'isRTL': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.1)),
            ),
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.language, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select your preferred language for the app. This will change the display language.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Language List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedLanguage == language['code'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryLight.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Text(
                      language['flag'],
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      language['name'],
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray800,
                      ),
                    ),
                    subtitle: Text(
                      language['nativeName'],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language['code'];
                      });
                      
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Language changed to ${language['name']}',
                            style: GoogleFonts.inter(),
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save language preference
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Language preference saved!',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
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
                  'Apply Language',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}