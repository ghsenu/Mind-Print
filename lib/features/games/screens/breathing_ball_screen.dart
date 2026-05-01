import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _BreathPhase { inhale, holdIn, exhale, holdOut }

class BreathingBallScreen extends StatefulWidget {
  const BreathingBallScreen({super.key});

  @override
  State<BreathingBallScreen> createState() => _BreathingBallScreenState();
}

class _BreathingBallScreenState extends State<BreathingBallScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalRounds = 5;

  late AnimationController _breathCtrl;
  int _roundsCompleted = 0;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    _breathCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _roundsCompleted++;
        if (_roundsCompleted >= _totalRounds) {
          _isDone = true;
          _breathCtrl.stop();
          WidgetsBinding.instance.addPostFrameCallback((_) => _showDoneDialog());
        } else {
          _breathCtrl.forward(from: 0.0);
        }
        if (mounted) setState(() {});
      }
    });
    _breathCtrl.forward();
  }

  _BreathPhase get _currentPhase {
    final v = _breathCtrl.value;
    if (v < 0.25) return _BreathPhase.inhale;
    if (v < 0.50) return _BreathPhase.holdIn;
    if (v < 0.75) return _BreathPhase.exhale;
    return _BreathPhase.holdOut;
  }

  double get _ballScale {
    final v = _breathCtrl.value;
    if (v < 0.25) return 0.5 + (v / 0.25) * 0.5;
    if (v < 0.50) return 1.0;
    if (v < 0.75) return 1.0 - ((v - 0.5) / 0.25) * 0.5;
    return 0.5;
  }

  List<Color> get _phaseColors {
    switch (_currentPhase) {
      case _BreathPhase.inhale:
        return [const Color(0xFF4776E6), const Color(0xFF6A8DFF)];
      case _BreathPhase.holdIn:
        return [const Color(0xFF6A1B9A), const Color(0xFF8E54E9)];
      case _BreathPhase.exhale:
        return [const Color(0xFF1B5E20), const Color(0xFF43A047)];
      case _BreathPhase.holdOut:
        return [const Color(0xFF1A237E), const Color(0xFF3949AB)];
    }
  }

  String get _phaseLabel {
    switch (_currentPhase) {
      case _BreathPhase.inhale:
        return 'Inhale';
      case _BreathPhase.holdIn:
        return 'Hold';
      case _BreathPhase.exhale:
        return 'Exhale';
      case _BreathPhase.holdOut:
        return 'Hold';
    }
  }

  void _showDoneDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Well done!',
          style: GoogleFonts.lora(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You completed $_totalRounds breathing rounds.\nHow do you feel?',
          style: GoogleFonts.lora(color: const Color(0xFF6B6B8A)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: GoogleFonts.lora(
                color: const Color(0xFF43A047),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _roundsCompleted = 0;
                _isDone = false;
              });
              _breathCtrl.forward(from: 0.0);
            },
            child: Text(
              'Again',
              style: GoogleFonts.lora(
                color: const Color(0xFF4776E6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A2E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Breathing Ball',
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _breathCtrl,
              builder: (context, _) {
                return Text(
                  'Round ${(_roundsCompleted + 1).clamp(1, _totalRounds)} of $_totalRounds',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                );
              },
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _breathCtrl,
              builder: (context, _) {
                return Text(
                  _phaseLabel,
                  style: GoogleFonts.lora(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _breathCtrl,
              builder: (context, _) {
                final colors = _phaseColors;
                return SizedBox(
                  width: 280,
                  height: 280,
                  child: Center(
                    child: Transform.scale(
                      scale: _ballScale,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [colors[1], colors[0]],
                            center: Alignment.center,
                            radius: 0.85,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[0].withOpacity(0.5),
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
            const Spacer(),
            if (!_isDone)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Stop Early',
                    style: GoogleFonts.lora(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
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
