import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/widgets/custom_bottom_nav.dart';
import '../../shared/constants/route_names.dart';
import '../models/activity_models.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  static const List<ActivityCategory> _categories = [
    ActivityCategory(
      title: 'Breathing Exercises',
      subtitle: '4 exercises · 3–7 min each',
      emoji: '🫧',
      color: Color(0xFFE0F2FE),
      route: AppRoutes.breathing,
      count: '4',
    ),
    ActivityCategory(
      title: 'Music Therapy',
      subtitle: 'Emotion-matched audio',
      emoji: '🎵',
      color: Color(0xFFF3E8FF),
      route: AppRoutes.musicTherapy,
      count: '8',
    ),
    ActivityCategory(
      title: 'Meditation',
      subtitle: 'Guided thought work',
      emoji: '🧘',
      color: Color(0xFFDCFCE7),
      route: AppRoutes.meditation,
      count: '5',
    ),
    ActivityCategory(
      title: 'CBT Exercises',
      subtitle: 'Cognitive reframe tools',
      emoji: '💬',
      color: Color(0xFFFEF9C3),
      route: AppRoutes.cbtExercises,
      count: '6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activities',
                      style: GoogleFonts.lora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your calm, one step at a time',
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        color: const Color(0xFF6B6B8A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Daily Suggestion Banner ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6ACFEF), Color(0xFFA855F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6ACFEF).withValues(alpha: 0.3),
                        blurRadius: 16,
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
                              'Today\'s Suggestion',
                              style: GoogleFonts.lora(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '4-7-8 Breathing',
                              style: GoogleFonts.lora(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Great for winding down before sleep',
                              style: GoogleFonts.lora(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.breathing,
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Start',
                            style: GoogleFonts.lora(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Section Label ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'CATEGORIES',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const Color(0xFF6B6B8A).withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Category List ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      _categories
                          .map((cat) => _CategoryRow(category: cat))
                          .toList(),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 1),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final ActivityCategory category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, category.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.subtitle,
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      color: const Color(0xFF6B6B8A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6B6B8A),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
