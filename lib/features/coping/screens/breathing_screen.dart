import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/activity_models.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  static const List<BreathingExercise> _exercises = [
    BreathingExercise(
      name: '4-7-8 Breathing',
      description: 'Calms the nervous system · Great for sleep',
      inhaleSecs: 4,
      holdSecs: 7,
      exhaleSecs: 8,
      durationMinutes: 5,
      color: Color(0xFF6ACFEF),
    ),
    BreathingExercise(
      name: 'Box Breathing',
      description: 'Builds focus · Used by Navy SEALs',
      inhaleSecs: 4,
      holdSecs: 4,
      exhaleSecs: 4,
      durationMinutes: 4,
      color: Color(0xFFA855F7),
    ),
    BreathingExercise(
      name: 'Belly Breathing',
      description: 'Reduces anxiety · Easy to learn',
      inhaleSecs: 4,
      holdSecs: 0,
      exhaleSecs: 6,
      durationMinutes: 3,
      color: Color(0xFF22C55E),
    ),
    BreathingExercise(
      name: 'Calming Breath',
      description: 'Quick stress relief · Any time, anywhere',
      inhaleSecs: 3,
      holdSecs: 2,
      exhaleSecs: 5,
      durationMinutes: 3,
      color: Color(0xFFF97316),
    ),
  ];

  BreathingExercise? _activeExercise;

  void _startExercise(BreathingExercise ex) {
    setState(() => _activeExercise = ex);
  }

  void _stopExercise() {
    setState(() => _activeExercise = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeExercise != null) {
      return _BreathingActiveScreen(
        exercise: _activeExercise!,
        onQuit: _stopExercise,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
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
                      'Breathing',
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
                  'Choose an exercise to begin',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      _exercises
                          .map(
                            (ex) => _ExerciseCard(
                              exercise: ex,
                              onTap: () => _startExercise(ex),
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

// ── Exercise list card ───────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final BreathingExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: exercise.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text('🫧', style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exercise.description,
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PhaseChip(label: 'Inhale ${exercise.inhaleSecs}s'),
                    if (exercise.holdSecs > 0) ...[
                      const SizedBox(width: 6),
                      _PhaseChip(label: 'Hold ${exercise.holdSecs}s'),
                    ],
                    const SizedBox(width: 6),
                    _PhaseChip(label: 'Exhale ${exercise.exhaleSecs}s'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: exercise.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Start',
                style: GoogleFonts.lora(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: exercise.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.lora(
          fontSize: 10,
          color: const Color(0xFF6B6B8A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Active breathing session ─────────────────────────────────────────────────

class _BreathingActiveScreen extends StatefulWidget {
  const _BreathingActiveScreen({required this.exercise, required this.onQuit});

  final BreathingExercise exercise;
  final VoidCallback onQuit;

  @override
  State<_BreathingActiveScreen> createState() => _BreathingActiveScreenState();
}

class _BreathingActiveScreenState extends State<_BreathingActiveScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;

  Timer? _phaseTimer;
  Timer? _sessionTimer;

  // Phase: 0=inhale, 1=hold, 2=exhale
  int _phase = 0;
  int _phaseSecsLeft = 0;
  int _sessionSecsLeft = 0;
  bool _paused = false;

  static const List<String> _phaseLabels = [
    'Inhale...',
    'Hold...',
    'Exhale...',
  ];
  static const List<String> _phaseHints = [
    "Breathe in slowly",
    "Hold still",
    "Let it all out",
  ];

  @override
  void initState() {
    super.initState();
    _sessionSecsLeft = widget.exercise.durationMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startPhase(0);
  }

  void _startPhase(int phase) {
    _phaseTimer?.cancel();
    final secs = _phaseSecs(phase);

    if (phase == 0) {
      _pulseController.duration = Duration(seconds: widget.exercise.inhaleSecs);
      _pulseController.forward(from: 0);
    } else if (phase == 1) {
      // hold — no scale change
    } else {
      _pulseController.duration = Duration(seconds: widget.exercise.exhaleSecs);
      _pulseController.reverse(from: 1);
    }

    setState(() {
      _phase = phase;
      _phaseSecsLeft = secs;
    });

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      if (_sessionSecsLeft <= 0) {
        _phaseTimer?.cancel();
        _sessionTimer?.cancel();
        _showCompletionDialog();
        return;
      }
      setState(() {
        _sessionSecsLeft--;
        _phaseSecsLeft--;
      });
      if (_phaseSecsLeft <= 0) {
        final next = _nextPhase(phase);
        if (next != null) _startPhase(next);
      }
    });
  }

  int _phaseSecs(int phase) {
    if (phase == 0) return widget.exercise.inhaleSecs;
    if (phase == 1) return widget.exercise.holdSecs;
    return widget.exercise.exhaleSecs;
  }

  int? _nextPhase(int current) {
    if (current == 0) {
      return widget.exercise.holdSecs > 0 ? 1 : 2;
    }
    if (current == 1) return 2;
    return 0;
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _pulseController.stop();
    } else {
      if (_phase == 0) {
        _pulseController.forward();
      } else if (_phase == 2) {
        _pulseController.reverse();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Session Complete 🎉',
              style: GoogleFonts.lora(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Great work! You completed ${widget.exercise.name}.',
              style: GoogleFonts.lora(color: const Color(0xFF6B6B8A)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onQuit();
                },
                child: Text(
                  'Done',
                  style: GoogleFonts.lora(
                    color: const Color(0xFF6ACFEF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session: ${_formatTime(_sessionSecsLeft)} remaining',
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Icon(Icons.water_drop_outlined, color: ex.color, size: 20),
                ],
              ),
            ),

            const Spacer(),

            // ── Pulsing circle ──────────────────────────────────────
            AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) {
                return Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: ex.color.withOpacity(0.25),
                      width: 12,
                    ),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ex.color.withOpacity(0.9),
                              ex.color.withOpacity(0.4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ex.color.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // ── Phase label ─────────────────────────────────────────
            Text(
              _paused ? 'Paused' : _phaseLabels[_phase],
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _paused ? 'Tap resume to continue' : _phaseHints[_phase],
              style: GoogleFonts.lora(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),

            const Spacer(),

            // ── Controls ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _togglePause,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
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
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Quit',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
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
