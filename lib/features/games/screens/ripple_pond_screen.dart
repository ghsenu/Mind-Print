import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class RipplePondScreen extends StatefulWidget {
  const RipplePondScreen({super.key});

  @override
  State<RipplePondScreen> createState() => _RipplePondScreenState();
}

class _RipplePondScreenState extends State<RipplePondScreen>
    with TickerProviderStateMixin {
  final List<_Ripple> _ripples = [];

  void _addRipple(Offset position) {
    final controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    final ripple = _Ripple(
      position: position,
      controller: controller,
      color: Colors.cyanAccent.withAlpha((0.6 * 255).round()),
    );

    setState(() {
      _ripples.add(ripple);
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _ripples.remove(ripple);
        });
        controller.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (var r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001529),
      body: GestureDetector(
        onTapDown: (details) => _addRipple(details.globalPosition),
        onPanUpdate: (details) {
          // Limit drag ripples to not overload
          if (Random().nextDouble() > 0.8) {
            _addRipple(details.globalPosition);
          }
        },
        child: Stack(
          children: [
            // Instructions
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Ripple Pond',
                        style: GoogleFonts.lora(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap or drag to create calming ripples...',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            // Ripples
            ..._ripples.map((ripple) {
              return AnimatedBuilder(
                animation: ripple.controller,
                builder: (context, child) {
                  final progress = ripple.controller.value;
                  final size = 300 * Curves.easeOutCubic.transform(progress);
                  final opacity = 1.0 - Curves.easeIn.transform(progress);

                  return Positioned(
                    left: ripple.position.dx - size / 2,
                    top: ripple.position.dy - size / 2,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ripple.color.withAlpha(
                            ((opacity * 0.8) * 255).round(),
                          ),
                          width: 2 + (1 - progress) * 3,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Ripple {
  _Ripple({
    required this.position,
    required this.controller,
    required this.color,
  });

  final Offset position;
  final AnimationController controller;
  final Color color;
}
