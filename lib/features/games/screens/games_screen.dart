import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/games/widgets/game_card.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  static const _games = [
    _GameData(
      title: 'Star Rain',
      subtitle: 'Focus on falling stars',
      icon: Icons.star,
      gradientColors: [Color(0xFF1A237E), Color(0xFF3949AB)],
      route: AppRoutes.starRain,
    ),
    _GameData(
      title: 'Bubble Pop',
      subtitle: 'Tap to pop and unwind',
      icon: Icons.bubble_chart,
      gradientColors: [Color(0xFF00695C), Color(0xFF00ACC1)],
      route: AppRoutes.bubblePop,
    ),
    _GameData(
      title: 'Memory Match',
      subtitle: 'Find the matching pairs',
      icon: Icons.grid_view,
      gradientColors: [Color(0xFF6A1B9A), Color(0xFFEC407A)],
      route: AppRoutes.memoryMatch,
    ),
    _GameData(
      title: 'Breathing Ball',
      subtitle: 'Breathe in, breathe out',
      icon: Icons.self_improvement,
      gradientColors: [Color(0xFF2E7D32), Color(0xFF00838F)],
      route: AppRoutes.breathingBall,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Games',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Relax your mind, one game at a time',
                style: GoogleFonts.lora(
                  fontSize: 14,
                  color: const Color(0xFF6B6B8A),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children:
                    _games
                        .map(
                          (g) => GameCard(
                            title: g.title,
                            subtitle: g.subtitle,
                            icon: g.icon,
                            gradientColors: g.gradientColors,
                            onTap: () => Navigator.pushNamed(context, g.route),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameData {
  const _GameData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String route;
}
