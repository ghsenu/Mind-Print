import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/analytics/providers/analytics_provider.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';
import 'package:mind_print/features/shared/providers/user_profile_provider.dart';
import 'package:mind_print/features/shared/widgets/page_indicator.dart';

class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  int _page = 0;
  bool _isSaving = false;

  // Q1 — mood (index into _moods list)
  int? _selectedMood;
  final List<_MoodOption> _moods = const [
    _MoodOption('😔', 'Stressed', 1),
    _MoodOption('😯', 'Sad', 2),
    _MoodOption('😐', 'Neutral', 3),
    _MoodOption('😊', 'Happy', 4),
    _MoodOption('🤩', 'Excited', 5),
  ];

  // Q2 — mind (multi-select)
  final Set<String> _mindSelections = {};
  final List<String> _mindOptions = const [
    'Study / Work',
    'Relationships',
    'Health',
    'Finances',
    'Nothing specific',
  ];

  // Q3 — sleep
  int? _selectedSleep;
  final List<_SimpleOption> _sleepOptions = const [
    _SimpleOption('😴', 'Great'),
    _SimpleOption('🙂', 'Okay'),
    _SimpleOption('😞', 'Poor'),
    _SimpleOption('😫', 'Terrible'),
  ];

  // Q4 — reason
  int? _selectedReason;
  final List<_SimpleOption> _reasonOptions = const [
    _SimpleOption('🧘', 'Manage stress'),
    _SimpleOption('📊', 'Track my mood'),
    _SimpleOption('💚', 'Improve mental health'),
    _SimpleOption('🔍', 'Just curious'),
  ];

  bool get _canProceed {
    switch (_page) {
      case 0:
        return _selectedMood != null;
      case 1:
        return _mindSelections.isNotEmpty;
      case 2:
        return _selectedSleep != null;
      case 3:
        return _selectedReason != null;
      default:
        return false;
    }
  }

  Future<void> _finish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final user = ref.read(currentUserProvider);
    try {
      if (user != null) {
        if (_selectedMood != null) {
          final mood = _moods[_selectedMood!];
          await ref
              .read(moodCheckinServiceProvider)
              .saveMoodCheckin(user.uid, mood.score, mood.label);
        }
        await ref.read(profileServiceProvider).updateFields(user.uid, {
          'onboardingCompleted': true,
        });
      }
    } catch (_) {
      // Firestore failure — user still proceeds; questionnaire may reappear next session
    } finally {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  void _next() {
    if (_page < 3) {
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) setState(() => _page--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (_page > 0)
                    GestureDetector(
                      onTap: _back,
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Color(0xFF1A1A2E),
                      ),
                    )
                  else
                    const SizedBox(width: 20),
                  const Spacer(),
                  PageIndicator(pageCount: 4, currentPage: _page),
                  const Spacer(),
                  Text(
                    '${_page + 1}/4',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF6B6B8A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Question content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder:
                    (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                child: KeyedSubtree(key: ValueKey(_page), child: _buildPage()),
              ),
            ),

            // Next / Finish button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canProceed ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C557E),
                    disabledBackgroundColor: const Color(
                      0xFF4C557E,
                    ).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            _page == 3 ? 'Get Started' : 'Continue',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case 0:
        return _buildMoodPage();
      case 1:
        return _buildMindPage();
      case 2:
        return _buildSleepPage();
      case 3:
        return _buildReasonPage();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Q1 ─────────────────────────────────────────────────────
  Widget _buildMoodPage() {
    return _PageShell(
      question: 'How are you feeling right now?',
      subtitle: 'Be honest — there are no wrong answers',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_moods.length, (i) {
          final selected = _selectedMood == i;
          return Flexible(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMood = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? const Color(0xFF4C557E).withValues(alpha: 0.12)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _moods[i].emoji,
                      style: TextStyle(fontSize: selected ? 40 : 32),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _moods[i].label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color:
                            selected
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFF6B6B8A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Q2 ─────────────────────────────────────────────────────
  Widget _buildMindPage() {
    return _PageShell(
      question: "What's been on your mind lately?",
      subtitle: 'Select all that apply',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            _mindOptions.map((opt) {
              final selected = _mindSelections.contains(opt);
              return GestureDetector(
                onTap:
                    () => setState(() {
                      if (selected) {
                        _mindSelections.remove(opt);
                      } else {
                        _mindSelections.add(opt);
                      }
                    }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF4C557E) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color:
                          selected
                              ? const Color(0xFF4C557E)
                              : const Color(0xFFDDE3EE),
                    ),
                    boxShadow: [
                      if (!selected)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                  child: Text(
                    opt,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // ── Q3 ─────────────────────────────────────────────────────
  Widget _buildSleepPage() {
    return _PageShell(
      question: 'How has your sleep been?',
      subtitle: 'Your sleep affects your mood more than you think',
      child: Column(
        children: List.generate(_sleepOptions.length, (i) {
          final selected = _selectedSleep == i;
          return _OptionRow(
            emoji: _sleepOptions[i].emoji,
            label: _sleepOptions[i].label,
            selected: selected,
            onTap: () => setState(() => _selectedSleep = i),
          );
        }),
      ),
    );
  }

  // ── Q4 ─────────────────────────────────────────────────────
  Widget _buildReasonPage() {
    return _PageShell(
      question: 'What brings you to MindPrint?',
      subtitle: "We'll personalise your experience around your goal",
      child: Column(
        children: List.generate(_reasonOptions.length, (i) {
          final selected = _selectedReason == i;
          return _OptionRow(
            emoji: _reasonOptions[i].emoji,
            label: _reasonOptions[i].label,
            selected: selected,
            onTap: () => setState(() => _selectedReason = i),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────

class _MoodOption {
  const _MoodOption(this.emoji, this.label, this.score);
  final String emoji;
  final String label;
  final int score;
}

class _SimpleOption {
  const _SimpleOption(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _PageShell extends StatelessWidget {
  const _PageShell({
    required this.question,
    required this.subtitle,
    required this.child,
  });
  final String question;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B6B8A),
            ),
          ),
          const SizedBox(height: 36),
          child,
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4C557E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF4C557E) : const Color(0xFFDDE3EE),
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
