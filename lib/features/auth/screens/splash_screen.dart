import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future<void>.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen background image ──────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'Assets/skybg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ── Dark grey overlay to highlight the bg & darken for legibility ─
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99222222), // dark grey 60% top
                    Color(0xBB1A1A2E), // deep dark-blue 73% bottom
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Large hi-res butterfly
                  Image.asset(
                    'Assets/butterfly.png',
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),

                  const SizedBox(height: 32),

                  // Subtitle
                  Text(
                    'Understand your emotions\none moment at time',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // "Mind Print" title with a small butterfly sitting above the 'T'
                  _MindPrintTitle(),

                  const Spacer(flex: 3),

                  // Bottom row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 36.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PRIVATE   •   SECURE   •   OFFLINE',
                          style: GoogleFonts.lora(
                            fontSize: 11,
                            letterSpacing: 1.8,
                            color: Colors.white.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders "Mind Print" in Lora with a small butterfly perched above the 'T'
class _MindPrintTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // We use a Stack to overlay the small butterfly on top of the 'T' letter
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // The full title text
        RichText(
          text: TextSpan(
            style: GoogleFonts.lora(
              fontSize: 44,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.4,
            ),
            children: const [
              TextSpan(text: 'Mind Prin'),
              // The 'T' — we add a small transparent spacer above it
              // so the butterfly has room; actual butterfly is in Stack
              TextSpan(text: 't'),
            ],
          ),
        ),

        // Small butterfly positioned above the 'T'
        // The 'T' is approximately the last character
        // offset from center-right of "Mind Print"
        Positioned(
          // Fine-tune these values to sit exactly above the 't'
          right: 0,
          top: -28,
          child: Image.asset(
            'Assets/butterfly_small.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }
}
