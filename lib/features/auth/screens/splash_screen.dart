import 'package:flutter/material.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('Assets/skybg.png', fit: BoxFit.cover),

          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Butterfly Logo (Commented out until PNG is provided to avoid the <filter/> crash)
                Image.asset(
                  'Assets/butterfly.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Mind Print',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Understand your emotions\none moment at time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom Row
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PRIVATE   •   SECURE   •   OFFLINE',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
