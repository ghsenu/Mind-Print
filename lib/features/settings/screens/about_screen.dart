import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About MindPrint',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'Assets/butterfly.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MindPrint',
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFACAEBD),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            
            _buildInfoCard(
              title: 'Our Mission',
              content: 'MindPrint is dedicated to empowering individuals on their mental wellness journey. By combining deep emotional analysis with therapeutic coping mechanisms, we aim to make mental health tracking intuitive, private, and effective.',
            ),
            
            const SizedBox(height: 20),
            
            _buildInfoCard(
              title: 'How It Works',
              content: 'We use advanced AI to analyze your daily journal entries, identifying emotional patterns and triggers. Based on these insights, we suggest personalized breathing exercises, meditation, and CBT activities to help you stay balanced.',
            ),
            
            const SizedBox(height: 20),
            
            _buildInfoCard(
              title: 'Your Privacy',
              content: 'At MindPrint, your data is yours. All emotional analysis happens securely, and we provide robust offline sync and biometric locking features to ensure your personal reflections stay private.',
            ),
            
            const SizedBox(height: 40),
            
            // Footer Info
            Text(
              '© 2026 MindPrint. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFACAEBD),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4C557E),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
