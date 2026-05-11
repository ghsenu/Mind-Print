import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({super.key});

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen>
    with TickerProviderStateMixin {
  static const _pastelColors = [
    Color(0xFFFFB3BA),
    Color(0xFFFFDFBA),
    Color(0xFFFFFFBA),
    Color(0xFFBAFFBA),
    Color(0xFFBAE1FF),
    Color(0xFFE8BAFF),
  ];

  final List<_Bubble> _bubbles = [];
  late Ticker _floatTicker;
  Timer? _spawnTimer;
  Duration _lastElapsed = Duration.zero;
  int _nextId = 0;
  Size _screenSize = Size.zero;
  int _popCount = 0;

  @override
  void initState() {
    super.initState();
    _floatTicker = createTicker(_onTick)..start();
    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: 1200),
      (_) => _spawnBubble(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_screenSize == Size.zero) {
      _screenSize = MediaQuery.of(context).size;
      for (int i = 0; i < 3; i++) {
        _spawnBubble(startMidScreen: true);
      }
    }
  }

  void _spawnBubble({bool startMidScreen = false}) {
    if (_bubbles.length >= 10 || _screenSize == Size.zero) return;
    final rng = math.Random();
    setState(() {
      _bubbles.add(
        _Bubble(
          id: _nextId++,
          x: rng.nextDouble(),
          y: startMidScreen ? 0.4 + rng.nextDouble() * 0.5 : 1.05,
          radius: 20 + rng.nextDouble() * 30,
          color: _pastelColors[rng.nextInt(_pastelColors.length)],
          speed: 0.025 + rng.nextDouble() * 0.03,
          driftPhase: rng.nextDouble() * math.pi * 2,
        ),
      );
    });
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (!mounted) return;
    setState(() {
      for (final b in _bubbles) {
        if (!b.isPopped) {
          b.y -= b.speed * dt;
          b.driftPhase += dt * 0.8;
          b.x += math.sin(b.driftPhase) * 0.0008;
          b.x = b.x.clamp(0.0, 1.0);
        } else {
          b.popScale += dt * 3.5;
        }
      }
      _bubbles.removeWhere(
        (b) => b.y < -0.15 || (b.isPopped && b.popScale > 1.6),
      );
    });
  }

  void _popBubble(_Bubble b) {
    if (b.isPopped) return;
    setState(() {
      b.isPopped = true;
      b.popScale = 1.0;
      _popCount++;
    });
  }

  @override
  void dispose() {
    _floatTicker.dispose();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Bubble Pop',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '$_popCount',
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00695C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bubbles
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  children:
                      _bubbles.map((b) {
                        final left = b.x * w - b.radius;
                        final top = b.y * h - b.radius;
                        final opacity =
                            b.isPopped
                                ? (1.6 - b.popScale).clamp(0.0, 1.0)
                                : 1.0;
                        return Positioned(
                          left: left,
                          top: top,
                          child: GestureDetector(
                            onTap: () => _popBubble(b),
                            child: Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: b.isPopped ? b.popScale : 1.0,
                                child: Container(
                                  width: b.radius * 2,
                                  height: b.radius * 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: b.color.withValues(alpha: 0.75),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: b.color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
            // Hint text at bottom
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Text(
                'Tap the bubbles to pop them',
                style: GoogleFonts.lora(
                  fontSize: 13,
                  color: const Color(0xFF6B6B8A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  _Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speed,
    required this.driftPhase,
  });

  final int id;
  double x;
  double y;
  final double radius;
  final Color color;
  final double speed;
  double driftPhase;
  bool isPopped = false;
  double popScale = 1.0;
}
