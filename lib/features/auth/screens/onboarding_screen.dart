import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';
import 'package:mind_print/features/shared/widgets/page_indicator.dart';
import 'package:mind_print/features/shared/widgets/primary_button.dart';

// ─────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────
class _PageData {
  const _PageData({
    required this.title,
    required this.description,
    required this.image,
  });
  final String title;
  final String description;
  final String image;
}

const _pages = [
  _PageData(
    title: 'Your Emotional\nFingerprint',
    description:
        'Mind Print helps you understand emotional\npatterns over time. Not labels. Not judgments.\nJust awareness that grows with you.',
    image: 'Assets/onboarding.png',
  ),
  _PageData(
    title: 'Express yourself,\nyour way',
    description:
        'Write or speak your thoughts.\nMind Print gently understands emotions\nfrom both text and voice.',
    image: 'Assets/onboarding.png',
  ),
  _PageData(
    title: 'Your privacy\ncomes first',
    description:
        'Your thoughts and voices stay private.\nYou are always in control of your data.',
    image: 'Assets/onboarding.png',
  ),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ── Large item count trick for infinite looping ──────────────
  static const int _totalVirtual = 30000;
  static const int _startIndex = 15000;

  // Initialized at declaration — avoids LateInitializationError on hot restart
  final PageController _pageCtrl = PageController(initialPage: _startIndex);
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start timer after first frame so controller is attached to the PageView
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      // nextPage automatically loops because of the virtual item count
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() => Navigator.pushReplacementNamed(context, AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: Stack(
        children: [
          // ── Main Column ──────────────────────────────────────────
          Column(
            children: [
              // Image — slides via one PageView with virtual infinite pages
              Expanded(
                flex: 57,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _totalVirtual,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (virtualIndex) {
                    final actual = virtualIndex % _pages.length;
                    setState(() => _current = actual);
                  },
                  itemBuilder: (_, virtualIndex) {
                    final i = virtualIndex % _pages.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Image.asset(
                        _pages[i].image,
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    );
                  },
                ),
              ),

              // White floating panel
              Expanded(
                flex: 43,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),

                        // Pagination — updates from _current
                        PageIndicator(
                          pageCount: _pages.length,
                          currentPage: _current,
                        ),

                        const SizedBox(height: 4),

                        // Text slides via AnimatedSwitcher — no second controller needed
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              final slideIn = Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation);
                              final slideOut = Tween<Offset>(
                                begin: const Offset(-1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation);
                              // incoming child slides from right, outgoing slides to left
                              return child.key == ValueKey(_current)
                                  ? SlideTransition(
                                    position: slideIn,
                                    child: child,
                                  )
                                  : SlideTransition(
                                    position: slideOut,
                                    child: child,
                                  );
                            },
                            child: _TextSlide(
                              key: ValueKey(_current),
                              page: _pages[_current],
                            ),
                          ),
                        ),

                        // Login button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: PrimaryButton(
                            label: 'Login',
                            onPressed: _goToLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Skip floats over top-right (respects status bar) ────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 16),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.lora(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A4A6A),
                    ),
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

// ─────────────────────────────────────────────────────────────
// Text content widget — keyed so AnimatedSwitcher detects change
// ─────────────────────────────────────────────────────────────
class _TextSlide extends StatelessWidget {
  const _TextSlide({super.key, required this.page});
  final _PageData page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 13,
              color: const Color(0xFF6B6B8A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
