import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Analytics',
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Journal Entries',
                        value: '24',
                        subtitle: 'Monthly total',
                        icon: Icons.edit_note,
                        accentColor: Color(0xFF5A8DFF),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Avg Mood',
                        value: '3.2',
                        subtitle: 'Steady state',
                        icon: Icons.sentiment_satisfied_alt,
                        accentColor: Color(0xFF4E7CF4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _WideSummaryCard(
                  title: 'Best Day',
                  value: 'Mon',
                  subtitle: 'Peak productivity',
                  icon: Icons.auto_awesome,
                  accentColor: Color(0xFF4E7CF4),
                ),
                const SizedBox(height: 18),
                Text(
                  'Deeper Insights',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5E6A8A),
                  ),
                ),
                const SizedBox(height: 12),
                _InsightPanel(
                  title: 'Emotional Fingerprint',
                  onTap: () {},
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 210,
                        child: Center(
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: CustomPaint(
                              painter: _RadarChartPainter(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 74,
                                    height: 74,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9CC9FF)
                                          .withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9CC9FF)
                                          .withOpacity(0.35),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const Positioned(
                                    top: 18,
                                    child: _FingerprintLabel(
                                      label: 'Anxiety',
                                      value: '35%',
                                    ),
                                  ),
                                  const Positioned(
                                    left: 8,
                                    top: 78,
                                    child: _FingerprintLabel(
                                      label: 'Anxiety',
                                      value: '35%',
                                      alignRight: true,
                                    ),
                                  ),
                                  const Positioned(
                                    right: 8,
                                    top: 78,
                                    child: _FingerprintLabel(
                                      label: 'Anxiety',
                                      value: '35%',
                                    ),
                                  ),
                                  const Positioned(
                                    bottom: 18,
                                    child: _FingerprintLabel(
                                      label: 'Anxiety',
                                      value: '35%',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analysis of recurring emotional states.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF8FA1BF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _InsightPanel(
                  title: 'Mood Prediction',
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8E8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Stable +',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2FAD58),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Likely to remain positive for the next 48 hours based on routine.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.5,
                          color: const Color(0xFF8FA1BF),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          minHeight: 4,
                          value: 0.78,
                          backgroundColor: Color(0xFFE4EFFC),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF27C16B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _InsightPanel(
                  title: 'Cognitive Patterns',
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '3 patterns',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5A8DFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Identified links between evening studies and high cortisol markers.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.5,
                          color: const Color(0xFF8FA1BF),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          _PatternChip(label: 'A', tint: Color(0xFF8FB6FF)),
                          SizedBox(width: 8),
                          _PatternChip(label: 'B', tint: Color(0xFFC6D6F5)),
                          SizedBox(width: 8),
                          _PatternChip(label: 'C', tint: Color(0xFFE7D3A5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB6D4F5).withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6E7B99),
                  ),
                ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C2D57),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF8FA1BF),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideSummaryCard extends StatelessWidget {
  const _WideSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB6D4F5).withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6E7B99),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C2D57),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF8FA1BF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor),
          ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.title,
    required this.child,
    required this.onTap,
  });

  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB6D4F5).withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2A395B),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8FA1BF),
                    ),
                  ],
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FingerprintLabel extends StatelessWidget {
  const _FingerprintLabel({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFB02E),
          ),
        ),
        Text(
          value,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF8FA1BF),
          ),
        ),
      ],
    );
  }
}

class _PatternChip extends StatelessWidget {
  const _PatternChip({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF35507D),
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFD7E7FA);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5A8DFF).withOpacity(0.18);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF2F80ED);

    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 3), gridPaint);
    }

    for (var i = 0; i < 5; i++) {
      final angle = -pi / 2 + (2 * pi * i / 5);
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);
    }

    final points = <Offset>[];
    const values = [0.85, 0.78, 0.68, 0.73, 0.82];
    for (var i = 0; i < values.length; i++) {
      final angle = -pi / 2 + (2 * pi * i / values.length);
      points.add(
        Offset(
          center.dx + radius * values[i] * cos(angle),
          center.dy + radius * values[i] * sin(angle),
        ),
      );
    }

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()..color = const Color(0xFF2F80ED),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
