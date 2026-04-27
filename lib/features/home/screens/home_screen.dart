import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/chatbot/screens/chatbot_screen.dart';
import 'package:mind_print/features/journal/screens/voice_journal_screen.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentMoodIndex = 2;

  final List<_MoodData> _moods = [
    const _MoodData('😔', 'Stressed'),
    const _MoodData('😯', 'Sad'),
    const _MoodData('😐', 'Neutral'),
    const _MoodData('😊', 'Happy'),
    const _MoodData('🤩', 'Overjoy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        'https://api.dicebear.com/7.x/avataaars/png?seed=Michael',
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          color: const Color(0xFF6B6B8A),
                        ),
                        children: [
                          const TextSpan(text: 'Hi, '),
                          TextSpan(
                            text: 'Michael',
                            style: GoogleFonts.lora(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _NotificationBell(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Greeting ──────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'Good Morning!',
                      style: GoogleFonts.lora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        color: const Color(0xFF6B6B8A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Mood Row ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_moods.length, (index) {
                    final mood = _moods[index];
                    final isSelected = _currentMoodIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _currentMoodIndex = index),
                      child: Column(
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood.label,
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF6B6B8A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // ── Insight Card ──────────────────────────────────────────
              _InsightCard(dominantEmotion: _moods[_currentMoodIndex].label),

              const SizedBox(height: 24),

              // ── Quick Actions Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'QUICK ACTIONS',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const Color(0xFF6B6B8A).withOpacity(0.7),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Action Grid ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _ActionCard(
                      icon: Icons.edit_outlined,
                      title: 'Journal',
                      subtitle: 'Write your thoughts',
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0EA5E9),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.journal),
                    ),
                    _ActionCard(
                      icon: Icons.mic_none_outlined,
                      title: 'Activities',
                      subtitle: 'Speak your mind',
                      iconBg: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFEF4444),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.coping),
                    ),
                    _ActionCard(
                      icon: Icons.bar_chart_outlined,
                      title: 'Games',
                      subtitle: 'View your patterns',
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFFA855F7),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
                    ),
                    _ActionCard(
                      icon: Icons.favorite_border_outlined,
                      title: 'Emotional Fingerprint',
                      subtitle: 'Exercises & music',
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF22C55E),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _CustomBottomNav(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _MoodData {
  const _MoodData(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none, color: Color(0xFF1A1A2E)),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.dominantEmotion});
  final String dominantEmotion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Today's Insight",
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '98% match',
                          style: GoogleFonts.lora(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DOMINANT EMOTION',
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: const Color(0xFF6B6B8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dominantEmotion,
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          size: 14,
                          color: Color(0xFF0EA5E9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Calm · 78%',
                          style: GoogleFonts.lora(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0EA5E9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress Circle Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF0F9FF),
                  width: 8,
                ),
              ),
              child: Center(
                child: Text(
                  '78%',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0EA5E9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.lora(
                fontSize: 11,
                color: const Color(0xFF6B6B8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_filled,
            label: 'Home',
            isSelected: true,
            onTap: () {}, // Already home
          ),
          _NavIcon(
            icon: Icons.psychology_outlined,
            label: 'Mood Predic',
            onTap: () => Navigator.pushNamed(context, AppRoutes.coping),
          ),
          // Middle Button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBotScreen()),
            ),
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x660EA5E9),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
            ),
          ),
          _NavIcon(
            icon: Icons.bar_chart_outlined,
            label: 'Analytics',
            onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
          ),
          _NavIcon(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF0EA5E9) : const Color(0xFF6B6B8A);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}