import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZenCanvasScreen extends StatefulWidget {
  const ZenCanvasScreen({super.key});

  @override
  State<ZenCanvasScreen> createState() => _ZenCanvasScreenState();
}

class _ZenCanvasScreenState extends State<ZenCanvasScreen>
    with SingleTickerProviderStateMixin {
  final List<_DrawnPoint> _points = [];
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30),
    )..addListener(() {
      // Continuously age points and remove old ones
      final now = DateTime.now();
      setState(() {
        _points.removeWhere(
          (p) => now.difference(p.time).inMilliseconds > 2500,
        );
      });
    });
    _fadeController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _addPoint(Offset position) {
    setState(() {
      _points.add(_DrawnPoint(position: position, time: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        onPanStart: (details) => _addPoint(details.globalPosition),
        onPanUpdate: (details) => _addPoint(details.globalPosition),
        child: Stack(
          children: [
            // Canvas for drawing
            CustomPaint(
              painter: _ZenPainter(_points, DateTime.now()),
              size: Size.infinite,
            ),
            // UI
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
                        'Zen Canvas',
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
                    'Draw to clear your mind. Thoughts fade away...',
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawnPoint {
  _DrawnPoint({required this.position, required this.time});
  final Offset position;
  final DateTime time;
}

class _ZenPainter extends CustomPainter {
  _ZenPainter(this.points, this.currentTime);

  final List<_DrawnPoint> points;
  final DateTime currentTime;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // If points are drawn too far apart in time, they belong to different strokes
      if (p2.time.difference(p1.time).inMilliseconds > 100) {
        continue;
      }

      final age = currentTime.difference(p1.time).inMilliseconds;
      if (age < 2500) {
        final opacity = 1.0 - (age / 2500.0);
        paint.color = Colors.amberAccent.withAlpha(
          ((opacity * 0.8) * 255).round(),
        );
        paint.strokeWidth = 4.0 + (opacity * 6.0); // Fades and shrinks

        // Draw line segment
        canvas.drawLine(p1.position, p2.position, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZenPainter oldDelegate) => true;
}
