import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/activity_models.dart';

class CbtScreen extends StatelessWidget {
  const CbtScreen({super.key});

  static const List<CbtExercise> _exercises = [
    CbtExercise(
      title: 'Thought Record',
      description: 'Challenge negative automatic thoughts',
      emoji: '📝',
      color: Color(0xFF6ACFEF),
      steps: [
        'Describe the situation that triggered the thought',
        'Write down the automatic thought',
        'Rate your emotion intensity (0–100%)',
        'Find evidence FOR the thought',
        'Find evidence AGAINST the thought',
        'Write a balanced alternative thought',
        'Re-rate your emotion after reframing',
      ],
    ),
    CbtExercise(
      title: 'Gratitude Check',
      description: 'Shift focus to what is going well',
      emoji: '🌟',
      color: Color(0xFFEAB308),
      steps: [
        'Name 3 things you are grateful for today',
        'For each one, write WHY it matters to you',
        'Notice how your body feels as you write',
        'Identify one person to silently thank',
        'Set one positive intention for tomorrow',
      ],
    ),
    CbtExercise(
      title: '5-4-3-2-1 Grounding',
      description: 'Anchor yourself in the present moment',
      emoji: '🌿',
      color: Color(0xFF22C55E),
      steps: [
        'Name 5 things you can SEE right now',
        'Name 4 things you can TOUCH or feel',
        'Name 3 things you can HEAR',
        'Name 2 things you can SMELL',
        'Name 1 thing you can TASTE',
        'Take 3 slow deep breaths',
      ],
    ),
    CbtExercise(
      title: 'Cognitive Reframe',
      description: 'See the situation from a new angle',
      emoji: '🔄',
      color: Color(0xFFA855F7),
      steps: [
        'Describe the situation in one sentence',
        'Identify the "worst case" fear',
        'Identify the "best case" possibility',
        'What is the MOST LIKELY outcome?',
        'What would you tell a friend in this situation?',
        'Write a more balanced perspective',
      ],
    ),
    CbtExercise(
      title: 'Worry Time',
      description: 'Schedule and contain your worries',
      emoji: '⏱️',
      color: Color(0xFFF97316),
      steps: [
        'Set a 10-minute worry window (not now)',
        'When a worry arises, note it briefly',
        'Remind yourself: "I\'ll think about this during worry time"',
        'During worry time: write each worry down',
        'Ask: Is this in my control?',
        'For things in control: write one action step',
        'For things not in control: practice letting go',
      ],
    ),
    CbtExercise(
      title: 'Self-Compassion Break',
      description: 'Treat yourself with the kindness you deserve',
      emoji: '💛',
      color: Color(0xFFEC4899),
      steps: [
        'Acknowledge: "This is a moment of suffering"',
        'Recognize: "Suffering is part of every human life"',
        'Place a hand on your heart',
        'Say: "May I be kind to myself in this moment"',
        'Say: "May I give myself the compassion I need"',
        'Sit quietly for 1 minute and breathe gently',
      ],
    ),
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
                      'CBT Exercises',
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
                  'Science-backed tools to reframe your thinking',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'EXERCISES',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const Color(0xFF6B6B8A).withOpacity(0.7),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      _exercises.map((ex) => _CbtCard(exercise: ex)).toList(),
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

class _CbtCard extends StatelessWidget {
  const _CbtCard({required this.exercise});

  final CbtExercise exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _CbtDetailScreen(exercise: exercise),
            ),
          ),
      child: Container(
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
                color: exercise.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  exercise.emoji,
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
                    exercise.title,
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
                  Text(
                    '${exercise.steps.length} steps',
                    style: GoogleFonts.lora(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: exercise.color,
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

// ── CBT detail / step-by-step view ──────────────────────────────────────────

class _CbtDetailScreen extends StatefulWidget {
  const _CbtDetailScreen({required this.exercise});

  final CbtExercise exercise;

  @override
  State<_CbtDetailScreen> createState() => _CbtDetailScreenState();
}

class _CbtDetailScreenState extends State<_CbtDetailScreen> {
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final allDone = _completed.length == ex.steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  Expanded(
                    child: Text(
                      ex.title,
                      style: GoogleFonts.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  Text(ex.emoji, style: const TextStyle(fontSize: 28)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                ex.description,
                style: GoogleFonts.lora(
                  fontSize: 14,
                  color: const Color(0xFF6B6B8A),
                ),
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:
                      ex.steps.isEmpty
                          ? 0
                          : _completed.length / ex.steps.length,
                  minHeight: 6,
                  backgroundColor: ex.color.withOpacity(0.12),
                  color: ex.color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: Text(
                '${_completed.length} of ${ex.steps.length} steps',
                style: GoogleFonts.lora(
                  fontSize: 12,
                  color: ex.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Steps
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ex.steps.length,
                itemBuilder: (context, i) {
                  final done = _completed.contains(i);
                  return GestureDetector(
                    onTap:
                        () => setState(() {
                          if (done) {
                            _completed.remove(i);
                          } else {
                            _completed.add(i);
                          }
                        }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: done ? ex.color.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              done
                                  ? ex.color.withOpacity(0.3)
                                  : Colors.transparent,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(done ? 0.01 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  done ? ex.color : ex.color.withOpacity(0.1),
                            ),
                            child: Center(
                              child:
                                  done
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                      : Text(
                                        '${i + 1}',
                                        style: GoogleFonts.lora(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ex.color,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              ex.steps[i],
                              style: GoogleFonts.lora(
                                fontSize: 14,
                                color:
                                    done
                                        ? const Color(0xFF6B6B8A)
                                        : const Color(0xFF1A1A2E),
                                decoration:
                                    done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Done button
            if (allDone)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: ex.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ex.color.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Complete ✓',
                        style: GoogleFonts.lora(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
}
