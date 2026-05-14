import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/analytics/providers/analytics_provider.dart';
import 'package:mind_print/features/analytics/services/analytics_service.dart';
import 'package:mind_print/features/shared/models/prediction.dart';
import 'package:mind_print/features/shared/widgets/custom_bottom_nav.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  static String _trendLabel(String trend) {
    switch (trend) {
      case 'improving':
        return 'Improving ↑';
      case 'declining':
        return 'Declining ↓';
      default:
        return 'Stable +';
    }
  }

  static Color _trendColor(String trend) {
    switch (trend) {
      case 'improving':
        return const Color(0xFF2FAD58);
      case 'declining':
        return const Color(0xFFD94F4F);
      default:
        return const Color(0xFF2FAD58);
    }
  }

  static Color _trendBg(String trend) {
    switch (trend) {
      case 'improving':
        return const Color(0xFFE8F8E8);
      case 'declining':
        return const Color(0xFFFFECEC);
      default:
        return const Color(0xFFE8F8E8);
    }
  }

  static String _trendDescription(String trend) {
    switch (trend) {
      case 'improving':
        return 'Your mood has been improving over recent entries. Keep it up!';
      case 'declining':
        return 'Your mood has been declining recently. Consider trying a coping activity.';
      default:
        return 'Likely to remain stable for now based on your recent entries.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final predictionAsync = ref.watch(latestPredictionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FBFF),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: summaryAsync.when(
                loading:
                    () => const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5A8DFF),
                        ),
                      ),
                    ),
                error:
                    (_, __) =>
                        _buildContent(context, AnalyticsSummary.empty(), null),
                data:
                    (summary) => _buildContent(
                      context,
                      summary,
                      predictionAsync.valueOrNull,
                    ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(selectedIndex: 3),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AnalyticsSummary summary,
    Prediction? prediction,
  ) {
    final trend = prediction?.trend ?? 'stable';
    final avgMoodDisplay =
        summary.avgMood > 0 ? summary.avgMood.toStringAsFixed(1) : '—';

    return Column(
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
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Journal Entries',
                value: summary.totalEntries.toString(),
                subtitle: 'Recent total',
                icon: Icons.edit_note,
                accentColor: const Color(0xFF5A8DFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Avg Mood',
                value: avgMoodDisplay,
                subtitle:
                    summary.totalEntries > 0
                        ? 'Tracked mood'
                        : 'No entries yet',
                icon: Icons.sentiment_satisfied_alt,
                accentColor: const Color(0xFF4E7CF4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _WideSummaryCard(
          title: 'Best Day',
          value: summary.bestDay,
          subtitle: summary.bestDay == '—' ? 'No data yet' : 'Highest avg mood',
          icon: Icons.auto_awesome,
          accentColor: const Color(0xFF4E7CF4),
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

        // Emotional Fingerprint
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
                      painter: _RadarChartPainter(
                        values: summary.emotionValues,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF9CC9FF,
                              ).withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF9CC9FF,
                              ).withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            top: 18,
                            child: _FingerprintLabel(
                              label: summary.emotionLabels[0],
                              value: _pct(summary.emotionValues[0]),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 78,
                            child: _FingerprintLabel(
                              label: summary.emotionLabels[4],
                              value: _pct(summary.emotionValues[4]),
                              alignRight: true,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 78,
                            child: _FingerprintLabel(
                              label: summary.emotionLabels[1],
                              value: _pct(summary.emotionValues[1]),
                            ),
                          ),
                          Positioned(
                            bottom: 18,
                            child: _FingerprintLabel(
                              label: summary.emotionLabels[2],
                              value: _pct(summary.emotionValues[2]),
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

        // Mood Prediction
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
                  color: _trendBg(trend),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _trendLabel(trend),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _trendColor(trend),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _trendDescription(trend),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.5,
                  color: const Color(0xFF8FA1BF),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value:
                      prediction != null
                          ? (prediction.averageMood / 5.0).clamp(0.0, 1.0)
                          : 0.0,
                  backgroundColor: const Color(0xFFE4EFFC),
                  valueColor: AlwaysStoppedAnimation<Color>(_trendColor(trend)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cognitive Patterns
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
                  summary.distortionCounts.isEmpty
                      ? 'No patterns yet'
                      : '${summary.distortionCounts.length} pattern${summary.distortionCounts.length == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A8DFF),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                summary.distortionCounts.isEmpty
                    ? 'Write more journal entries to uncover cognitive patterns.'
                    : 'Identified cognitive patterns from your journal history.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.5,
                  color: const Color(0xFF8FA1BF),
                ),
              ),
              if (summary.distortionCounts.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _patternChipColors
                          .take(summary.distortionCounts.length)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final name = summary.distortionCounts.keys
                                .elementAt(entry.key);
                            final short =
                                name
                                    .split('-')
                                    .map((w) => w[0].toUpperCase())
                                    .join();
                            return _PatternChip(
                              label: short,
                              tint: entry.value,
                            );
                          })
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static const List<Color> _patternChipColors = [
    Color(0xFF8FB6FF),
    Color(0xFFC6D6F5),
    Color(0xFFE7D3A5),
    Color(0xFFA8D8B9),
    Color(0xFFE8B4B8),
  ];

  static String _pct(double value) => '${(value * 100).round()}%';
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
            color: const Color(0xFFB6D4F5).withValues(alpha: 0.15),
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
            color: const Color(0xFFB6D4F5).withValues(alpha: 0.15),
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
              color: accentColor.withValues(alpha: 0.12),
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
            color: const Color(0xFFB6D4F5).withValues(alpha: 0.14),
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
                    const Icon(Icons.chevron_right, color: Color(0xFF8FA1BF)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.35),
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
  const _RadarChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;

    final gridPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFD7E7FA);

    final fillPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF5A8DFF).withValues(alpha: 0.18);

    final outlinePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF2F80ED);

    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 3), gridPaint);
    }

    final axisCount = values.length;
    for (var i = 0; i < axisCount; i++) {
      final angle = -pi / 2 + (2 * pi * i / axisCount);
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i].clamp(0.05, 1.0);
      final angle = -pi / 2 + (2 * pi * i / values.length);
      points.add(
        Offset(
          center.dx + radius * v * cos(angle),
          center.dy + radius * v * sin(angle),
        ),
      );
    }

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = const Color(0xFF2F80ED));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter old) => old.values != values;
}
