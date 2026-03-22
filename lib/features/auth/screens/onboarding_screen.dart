import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Loop back to the first screen
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB1D8FB), // Light blue background
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildPage(
                  title: 'Your Emotional\nFingerprint',
                  description:
                      'Mind Print helps you understand\nemotional patterns over time.\nNot labels. Not judgments.\nJust awareness that grows with you.',
                ),
                _buildPage(
                  title: 'Express yourself,\nyour way',
                  description:
                      'Write or speak your thoughts. Mind Print gently\nunderstands emotions from both\ntext and voice.',
                  topWidget: _buildMicAndDocIcons(),
                ),
                _buildPage(
                  title: 'Your privacy comes\nfirst',
                  description:
                      'Your thoughts and voices\nstay private. All entries are protected with\nencryption and biometric security. You are always in\ncontrol of your data.',
                ),
              ],
            ),

            // Skip Button at top right
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
            ),

            // Page Indicators
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildDot(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? const Color(0xFF3333CC)
                : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildMicAndDocIcons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0), // Space before text
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_outlined, size: 70, color: Colors.black87),
          const SizedBox(width: 80),
          Icon(Icons.description_outlined, size: 70, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    Widget? topWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (topWidget != null) topWidget else const SizedBox(height: 50),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 60), // Pushes text up slightly
        ],
      ),
    );
  }
}
