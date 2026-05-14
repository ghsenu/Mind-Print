import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_models.dart';
import '../services/audio_service.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  static const List<MeditationSession> _sessions = [
    MeditationSession(
      title: 'Morning Clarity',
      description: 'Start your day with focused intention',
      durationMinutes: 5,
      color: Color(0xFF6ACFEF),
    ),
    MeditationSession(
      title: 'Stress Release',
      description: 'Let go of tension and find stillness',
      durationMinutes: 10,
      color: Color(0xFFA855F7),
    ),
    MeditationSession(
      title: 'Body Scan',
      description: 'Reconnect with your physical sensations',
      durationMinutes: 15,
      color: Color(0xFF22C55E),
    ),
    MeditationSession(
      title: 'Loving Kindness',
      description: 'Cultivate compassion for self and others',
      durationMinutes: 10,
      color: Color(0xFFEC4899),
    ),
    MeditationSession(
      title: 'Deep Rest',
      description: 'Guided relaxation for full recovery',
      durationMinutes: 20,
      color: Color(0xFF0EA5E9),
    ),
  ];

  MeditationSession? _activeSession;
  int _selectedDuration = 10;
  int _moodBefore = 2;
  int _moodAfter = -1;

  final List<int> _durations = [5, 10, 20, 30];
  final List<String> _moodEmojis = ['😔', '😟', '😐', '😊', '🤩'];

  @override
  Widget build(BuildContext context) {
    if (_activeSession != null) {
      return _ActiveMeditationScreen(
        session: _activeSession!,
        durationMinutes: _selectedDuration,
        moodBefore: _moodBefore,
        onComplete: (moodAfter) {
          setState(() {
            _moodAfter = moodAfter;
            _activeSession = null;
          });
        },
        onQuit: () => setState(() => _activeSession = null),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1A1A2E),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Meditation',
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  'Guided sessions for a calmer mind',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Duration picker ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Duration',
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children:
                            _durations.map((d) {
                              final isSelected = d == _selectedDuration;
                              return Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () =>
                                          setState(() => _selectedDuration = d),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? const Color(0xFF6ACFEF)
                                              : const Color(0xFFF0FBFF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${d}m',
                                        style: GoogleFonts.lora(
                                          fontSize: 14,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF6B6B8A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Mood before ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you feeling?',
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          _moodEmojis.length,
                          (i) => GestureDetector(
                            onTap: () => setState(() => _moodBefore = i),
                            child: AnimatedScale(
                              scale: _moodBefore == i ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _moodEmojis[i],
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Before: ${_moodEmojis[_moodBefore]}',
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              color: const Color(0xFF6B6B8A),
                            ),
                          ),
                          Text(
                            _moodAfter >= 0
                                ? 'After: ${_moodEmojis[_moodAfter]}'
                                : 'After: —',
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              color: const Color(0xFF6B6B8A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'SESSIONS',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const Color(0xFF6B6B8A).withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Session list ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      _sessions
                          .map(
                            (s) => _SessionCard(
                              session: s,
                              onStart: () => setState(() => _activeSession = s),
                            ),
                          )
                          .toList(),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onStart});

  final MeditationSession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              color: session.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text('🧘', style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.description,
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: session.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${session.durationMinutes} min',
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: session.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: session.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Begin',
                style: GoogleFonts.lora(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: session.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active meditation timer ──────────────────────────────────────────────────

class _ActiveMeditationScreen extends ConsumerStatefulWidget {
  const _ActiveMeditationScreen({
    required this.session,
    required this.durationMinutes,
    required this.moodBefore,
    required this.onComplete,
    required this.onQuit,
  });

  final MeditationSession session;
  final int durationMinutes;
  final int moodBefore;
  final ValueChanged<int> onComplete;
  final VoidCallback onQuit;

  @override
  ConsumerState<_ActiveMeditationScreen> createState() =>
      _ActiveMeditationScreenState();
}

class _ActiveMeditationScreenState
    extends ConsumerState<_ActiveMeditationScreen>
    with SingleTickerProviderStateMixin {
  late int _secsLeft;
  Timer? _timer;
  bool _paused = false;
  late AnimationController _ripple;

  @override
  void initState() {
    super.initState();
    _secsLeft = widget.durationMinutes * 60;
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(audioServiceProvider)
          // TODO: paste Firebase Storage URL for meditation-ambient.mp3
          .loadAudio(
            'https://placeholder.invalid/meditation-ambient.mp3',
          )
          .then((_) {
            if (!mounted) return;
            ref.read(audioServiceProvider).play();
          });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      if (_secsLeft <= 0) {
        _timer?.cancel();
        ref.read(audioServiceProvider).stop();
        _showMoodAfterDialog();
        return;
      }
      setState(() => _secsLeft--);
    });
  }

  void _showMoodAfterDialog() {
    int selected = widget.moodBefore;
    final emojis = ['😔', '😟', '😐', '😊', '🤩'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder:
                (ctx, setS) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Session Complete 🎉',
                    style: GoogleFonts.lora(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'How do you feel now?',
                        style: GoogleFonts.lora(color: const Color(0xFF6B6B8A)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          emojis.length,
                          (i) => GestureDetector(
                            onTap: () => setS(() => selected = i),
                            child: AnimatedScale(
                              scale: selected == i ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Text(
                                emojis[i],
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onComplete(selected);
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.lora(
                          color: widget.session.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  String _format(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ripple.dispose();
    ref.read(audioServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.durationMinutes * 60;
    final progress = 1 - (_secsLeft / total);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session: ${_format(_secsLeft)} remaining',
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Icon(
                    Icons.self_improvement_rounded,
                    color: widget.session.color,
                    size: 20,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Progress ring + ripple
            AnimatedBuilder(
              animation: _ripple,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ripple
                    Opacity(
                      opacity: 1 - _ripple.value,
                      child: Container(
                        width: 260 + _ripple.value * 40,
                        height: 260 + _ripple.value * 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.session.color.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    // Progress ring
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        color: widget.session.color,
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🧘', style: const TextStyle(fontSize: 52)),
                        const SizedBox(height: 12),
                        Text(
                          _format(_secsLeft),
                          style: GoogleFonts.lora(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            Text(
              widget.session.title,
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.session.description,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _paused = !_paused);
                        if (_paused) {
                          ref.read(audioServiceProvider).pause();
                        } else {
                          ref.read(audioServiceProvider).play();
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Center(
                          child: Text(
                            _paused ? 'Resume' : 'Pause',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onQuit,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Quit',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
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
