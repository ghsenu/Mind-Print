import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/analytics/providers/analytics_provider.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/notifications/providers/notification_provider.dart';
import 'package:mind_print/features/shared/providers/user_profile_provider.dart';
import 'package:mind_print/features/shared/widgets/custom_bottom_nav.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentMoodIndex = 2;
  bool _showStressBanner = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(notificationServiceProvider).saveTokenToUserProfile(user.uid);
      }
    });
  }

  void _showMoodRecommendation(BuildContext context, int moodIndex) {
    final isStressed = moodIndex == 0;
    final emoji = isStressed ? '😔' : '😯';
    final label = isStressed ? 'Stressed' : 'Sad';
    final subtitle = isStressed
        ? "Let's help you reset and find some calm"
        : "You're not alone — here's something that might help";

    final recommendations = isStressed
        ? [
            _Recommendation(
              icon: Icons.air_outlined,
              color: const Color(0xFF0EA5E9),
              title: 'Breathing Exercise',
              description: 'Calm your nervous system in minutes',
              route: AppRoutes.breathing,
            ),
            _Recommendation(
              icon: Icons.sports_esports_outlined,
              color: const Color(0xFF8E54E9),
              title: 'Play a Game',
              description: 'Distract your mind with a fun activity',
              route: AppRoutes.games,
            ),
            _Recommendation(
              icon: Icons.self_improvement_outlined,
              color: const Color(0xFF11998E),
              title: 'Meditate',
              description: 'Ground yourself with a guided session',
              route: AppRoutes.meditation,
            ),
          ]
        : [
            _Recommendation(
              icon: Icons.music_note_outlined,
              color: const Color(0xFFFF6B6B),
              title: 'Music Therapy',
              description: 'Let music lift your spirits',
              route: AppRoutes.musicTherapy,
            ),
            _Recommendation(
              icon: Icons.edit_outlined,
              color: const Color(0xFF667EEA),
              title: 'Journal',
              description: 'Write out what you are feeling',
              route: AppRoutes.journal,
            ),
            _Recommendation(
              icon: Icons.sports_esports_outlined,
              color: const Color(0xFF8E54E9),
              title: 'Play a Game',
              description: 'Take a fun break to reset',
              route: AppRoutes.games,
            ),
          ];

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You seem $label',
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B6B8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFF6B6B8A),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 8),

              Text(
                'Things that might help',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: const Color(0xFF6B6B8A),
                ),
              ),
              const SizedBox(height: 12),

              // Activity rows
              ...recommendations.map(
                (rec) => _RecommendationTile(
                  recommendation: rec,
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, rec.route);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<_MoodData> _moods = [
    const _MoodData('😔', 'Stressed'),
    const _MoodData('😯', 'Sad'),
    const _MoodData('😐', 'Neutral'),
    const _MoodData('😊', 'Happy'),
    const _MoodData('🤩', 'Overjoy'),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final displayName = profile?.displayName ?? 'there';
    final avatarUrl =
        profile?.profilePhoto ??
        'https://api.dicebear.com/7.x/avataaars/png?seed=${profile?.userId ?? 'user'}';
    final prediction = ref.watch(latestPredictionProvider).valueOrNull;

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
                    GestureDetector(
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                          ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(avatarUrl),
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
                            text: displayName,
                            style: GoogleFonts.lora(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const _NotificationBell(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Stress Banner ─────────────────────────────────────────
              if (_showStressBanner &&
                  (prediction?.alertNeeded == true || _currentMoodIndex == 0))
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      children: [
                        const Text('😮‍💨', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You seem stressed',
                                style: GoogleFonts.lora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB91C1C),
                                ),
                              ),
                              Text(
                                'Try a breathing exercise to reset',
                                style: GoogleFonts.lora(
                                  fontSize: 12,
                                  color: const Color(0xFFEF4444),
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
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Try',
                              style: GoogleFonts.lora(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap:
                              () => setState(() => _showStressBanner = false),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 28),

              // ── Animated Mood Bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _moods.length,
                    (i) => _AnimatedMoodEmoji(
                      emoji: _moods[i].emoji,
                      label: _moods[i].label,
                      isSelected: _currentMoodIndex == i,
                      floatPhase: i * 0.2,
                      onTap: () async {
                        setState(() => _currentMoodIndex = i);
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          try {
                            await ref
                                .read(moodCheckinServiceProvider)
                                .saveMoodCheckin(
                                  user.uid,
                                  i + 1,
                                  _moods[i].label,
                                );
                          } catch (e) {
                            debugPrint('Failed to save mood check-in: $e');
                          }
                        }
                        if (i == 0 || i == 1) {
                          _showMoodRecommendation(context, i);
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

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
                    color: const Color(0xFF6B6B8A).withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Action Cards ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _ActionCard(
                      icon: Icons.edit_outlined,
                      title: 'Journal',
                      subtitle: 'Write your thoughts',
                      gradientColors: const [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                      animOffset: 0.0,
                      onTap:
                          () => Navigator.pushNamed(context, AppRoutes.journal),
                    ),
                    _ActionCard(
                      icon: Icons.mic_none_outlined,
                      title: 'Activities',
                      subtitle: 'Speak your mind',
                      gradientColors: const [
                        Color(0xFFFF6B6B),
                        Color(0xFFFF8E53),
                      ],
                      animOffset: 0.25,
                      onTap:
                          () => Navigator.pushNamed(context, AppRoutes.coping),
                    ),
                    _ActionCard(
                      icon: Icons.sports_esports_outlined,
                      title: 'Games',
                      subtitle: 'Play your way to calm',
                      gradientColors: const [
                        Color(0xFF4776E6),
                        Color(0xFF8E54E9),
                      ],
                      animOffset: 0.5,
                      onTap:
                          () => Navigator.pushNamed(context, AppRoutes.games),
                    ),
                    _ActionCard(
                      icon: Icons.favorite_border_outlined,
                      title: 'Reports',
                      subtitle: 'Exercises & music',
                      gradientColors: const [
                        Color(0xFF11998E),
                        Color(0xFF38EF7D),
                      ],
                      animOffset: 0.75,
                      onTap:
                          () => Navigator.pushNamed(context, AppRoutes.reports),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────

class _MoodData {
  const _MoodData(this.emoji, this.label);
  final String emoji;
  final String label;
}

// ─────────────────────────────────────────────────────────────
// Animated Mood Emoji
// ─────────────────────────────────────────────────────────────

class _AnimatedMoodEmoji extends StatefulWidget {
  const _AnimatedMoodEmoji({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.floatPhase,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final double floatPhase;
  final VoidCallback onTap;

  @override
  State<_AnimatedMoodEmoji> createState() => _AnimatedMoodEmojiState();
}

class _AnimatedMoodEmojiState extends State<_AnimatedMoodEmoji>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _floatAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      value: widget.floatPhase,
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: 0,
      end: -7,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.88), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.2), weight: 35),
    ]).animate(_bounceCtrl);
  }

  @override
  void didUpdateWidget(_AnimatedMoodEmoji old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _bounceCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  double get _displayScale {
    if (_bounceCtrl.isAnimating) return _scaleAnim.value;
    return widget.isSelected ? 1.2 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _bounceCtrl]),
        builder: (context, _) {
          return Column(
            children: [
              Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: Transform.scale(
                  scale: _displayScale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? const Color(0xFF4C557E).withValues(alpha: 0.12)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.lora(
                  fontSize: 11,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      widget.isSelected
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF6B6B8A),
                ),
                child: Text(widget.label),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Notification Bell
// ─────────────────────────────────────────────────────────────

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none, color: Color(0xFF1A1A2E)),
            if (unreadCount > 0)
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

// ─────────────────────────────────────────────────────────────
// Insight Card
// ─────────────────────────────────────────────────────────────

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
              color: Colors.black.withValues(alpha: 0.04),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      dominantEmotion,
                      key: ValueKey(dominantEmotion),
                      style: GoogleFonts.lora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                  width: 6,
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

// ─────────────────────────────────────────────────────────────
// Action Card — gradient + animated bubbles
// ─────────────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.animOffset,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final double animOffset;
  final VoidCallback? onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      value: widget.animOffset,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _BubblePainter(progress: _ctrl.value),
                    size: Size.infinite,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, color: Colors.white, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: GoogleFonts.lora(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.lora(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bubble Painter
// ─────────────────────────────────────────────────────────────

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * pi;

    // large blob — top-right, drifts slowly
    _draw(
      canvas,
      size,
      cx: size.width * 0.75 + sin(t * 0.7) * size.width * 0.12,
      cy: size.height * 0.25 + cos(t * 0.5) * size.height * 0.18,
      r: size.width * 0.38,
      opacity: 0.18,
    );

    // medium blob — bottom-left
    _draw(
      canvas,
      size,
      cx: size.width * 0.15 + sin(t * 0.4 + 1.2) * size.width * 0.1,
      cy: size.height * 0.75 + cos(t * 0.6 + 0.8) * size.height * 0.15,
      r: size.width * 0.28,
      opacity: 0.14,
    );

    // small blob — center, quicker drift
    _draw(
      canvas,
      size,
      cx: size.width * 0.5 + sin(t * 0.9 + 2.5) * size.width * 0.2,
      cy: size.height * 0.5 + cos(t * 0.8 + 1.0) * size.height * 0.2,
      r: size.width * 0.16,
      opacity: 0.10,
    );
  }

  void _draw(
    Canvas canvas,
    Size size, {
    required double cx,
    required double cy,
    required double r,
    required double opacity,
  }) {
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────
// Mood Recommendation helpers
// ─────────────────────────────────────────────────────────────

class _Recommendation {
  const _Recommendation({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.route,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String route;
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.recommendation,
    required this.onTap,
  });
  final _Recommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: recommendation.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: recommendation.color.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: recommendation.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                recommendation.icon,
                color: recommendation.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    recommendation.description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B6B8A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: recommendation.color,
            ),
          ],
        ),
      ),
    );
  }
}
