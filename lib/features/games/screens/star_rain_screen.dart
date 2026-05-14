import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class StarRainScreen extends StatefulWidget {
  const StarRainScreen({super.key});

  @override
  State<StarRainScreen> createState() => _StarRainScreenState();
}

class _StarRainScreenState extends State<StarRainScreen>
    with SingleTickerProviderStateMixin {
  static const int _starCount = 60;

  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final List<_Star> _stars = [];
  Size _screenSize = Size.zero;

  final _starPaint = Paint()..style = PaintingStyle.fill;
  final _burstPaint =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stars.isEmpty) {
      _screenSize = MediaQuery.of(context).size;
      _initStars();
    }
  }

  void _initStars() {
    final rng = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(
        _Star(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          speed: 0.05 + rng.nextDouble() * 0.13,
          size: 1.5 + rng.nextDouble() * 3.0,
          twinklePhase: rng.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (!mounted) return;
    final rng = math.Random();
    setState(() {
      for (final star in _stars) {
        star.y += star.speed * dt;
        star.twinklePhase += dt * 2.5;
        star.opacity = 0.4 + 0.6 * ((math.sin(star.twinklePhase) + 1) / 2);

        if (star.y > 1.02) {
          star.y = -0.02;
          star.x = rng.nextDouble();
        }

        if (star.isBursting) {
          star.burstProgress += dt * 2.5;
          if (star.burstProgress >= 1.0) {
            star.isBursting = false;
            star.burstProgress = 0.0;
          }
        }
      }
    });
  }

  void _onTapDown(TapDownDetails details) {
    final tap = details.localPosition;
    final w = _screenSize.width;
    final h = _screenSize.height;
    double minDist = double.infinity;
    _Star? nearest;

    for (final star in _stars) {
      final sx = star.x * w;
      final sy = star.y * h;
      final dist = math.sqrt(
        math.pow(tap.dx - sx, 2) + math.pow(tap.dy - sy, 2),
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = star;
      }
    }

    if (nearest != null && minDist < 40) {
      setState(() {
        nearest!.isBursting = true;
        nearest.burstProgress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A2E),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: _onTapDown,
            child: CustomPaint(
              painter: _StarPainter(
                stars: _stars,
                screenSize: _screenSize,
                starPaint: _starPaint,
                burstPaint: _burstPaint,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    'Focus on the stars...',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
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

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.twinklePhase,
  });

  double x;
  double y;
  final double speed;
  final double size;
  double twinklePhase;
  double opacity = 1.0;
  bool isBursting = false;
  double burstProgress = 0.0;
}

class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.stars,
    required this.screenSize,
    required this.starPaint,
    required this.burstPaint,
  });

  final List<_Star> stars;
  final Size screenSize;
  final Paint starPaint;
  final Paint burstPaint;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final sx = star.x * size.width;
      final sy = star.y * size.height;

      starPaint.color = Colors.white.withValues(alpha: star.opacity);
      canvas.drawCircle(Offset(sx, sy), star.size, starPaint);

      if (star.isBursting) {
        final progress = star.burstProgress;
        final burstRadius = star.size + 20 * progress;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        burstPaint.color = Colors.white.withValues(alpha: opacity);

        const rayCount = 8;
        for (int r = 0; r < rayCount; r++) {
          final angle = (r / rayCount) * math.pi * 2;
          final innerRadius = star.size + 4;
          final outerRadius = burstRadius;
          canvas.drawLine(
            Offset(
              sx + math.cos(angle) * innerRadius,
              sy + math.sin(angle) * innerRadius,
            ),
            Offset(
              sx + math.cos(angle) * outerRadius,
              sy + math.sin(angle) * outerRadius,
            ),
            burstPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}
