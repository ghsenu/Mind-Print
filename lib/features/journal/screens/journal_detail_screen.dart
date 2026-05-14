import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/journal/providers/journal_provider.dart';
import 'package:mind_print/features/shared/models/emotion_result.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';

class JournalDetailScreen extends ConsumerStatefulWidget {
  const JournalDetailScreen({super.key, required this.entry});

  final JournalEntry entry;

  @override
  ConsumerState<JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  EmotionResult? _emotionResult;
  bool _loadingResult = false;
  bool _deleting = false;

  static const Map<int, Map<String, dynamic>> _moodMeta = {
    1: {
      'label': 'Stressed',
      'color': Color(0xFFFAE5D4),
      'text': Color(0xFFD5743D),
    },
    2: {'label': 'Sad', 'color': Color(0xFFE6F0FF), 'text': Color(0xFF0056D2)},
    3: {
      'label': 'Neutral',
      'color': Color(0xFFF3E8FF),
      'text': Color(0xFF7E22CE),
    },
    4: {'label': 'Calm', 'color': Color(0xFFE4F8EA), 'text': Color(0xFF28A745)},
    5: {
      'label': 'Joyful',
      'color': Color(0xFFFDF0CF),
      'text': Color(0xFFF25A12),
    },
  };

  static const Map<String, String> _emotionEmoji = {
    'joy': '😊',
    'sadness': '😢',
    'anger': '😠',
    'fear': '😰',
    'surprise': '😲',
    'disgust': '🤢',
    'neutral': '😐',
  };

  @override
  void initState() {
    super.initState();
    if (widget.entry.isAnalyzed) _loadEmotionResult();
  }

  Future<void> _loadEmotionResult() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _loadingResult = true);
    try {
      final result = await ref
          .read(journalServiceProvider)
          .getEmotionResult(user.uid, widget.entry.id);
      if (mounted) setState(() => _emotionResult = result);
    } finally {
      if (mounted) setState(() => _loadingResult = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text(
              'This entry and its analysis will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _deleting = true);
    try {
      await ref
          .read(journalServiceProvider)
          .deleteEntry(user.uid, widget.entry.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  String _formatFullDate(DateTime dt) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final mood = _moodMeta[entry.moodScore] ?? _moodMeta[3]!;
    final isVoice = entry.entryType == 'voice';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isVoice ? 'Voice Entry' : 'Text Entry',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          if (_deleting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD5473D)),
              onPressed: _confirmDelete,
              tooltip: 'Delete entry',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Text(
              _formatFullDate(entry.createdAt),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF8A93A6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Mood + type badges
            Row(
              children: [
                _badge(
                  (mood['label'] as String).toUpperCase(),
                  mood['color'] as Color,
                  mood['text'] as Color,
                ),
                const SizedBox(width: 8),
                _badge(
                  isVoice ? 'VOICE' : 'TEXT',
                  const Color(0xFFFDECE4),
                  const Color(0xFFF25A12),
                ),
                if (entry.isAnalyzed) ...[
                  const SizedBox(width: 8),
                  _badge(
                    'ANALYZED',
                    const Color(0xFFE4F8EA),
                    const Color(0xFF28A745),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Content card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isVoice ? Icons.mic_none : Icons.edit_note,
                        size: 16,
                        color: const Color(0xFF8A93A6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isVoice ? 'Transcript' : 'Journal Entry',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A93A6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.content.isNotEmpty
                        ? entry.content
                        : 'No content recorded.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emotion analysis section
            if (entry.isAnalyzed) ...[
              if (_loadingResult)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: Color(0xFF89A8C8)),
                  ),
                )
              else if (_emotionResult != null) ...[
                _buildEmotionSection(_emotionResult!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSection(EmotionResult result) {
    final emoji = _emotionEmoji[result.primaryEmotion] ?? '😐';
    final label =
        result.primaryEmotion[0].toUpperCase() +
        result.primaryEmotion.substring(1);
    final pct = (result.intensity * 100).round();

    return Column(
      children: [
        // Primary emotion
        _card(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF88A6C5), width: 3),
                  color: const Color(0xFFF0F5FA),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'AI ANALYSIS',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6E8BAA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF162033),
                      ),
                    ),
                    Text(
                      '$pct% confidence',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF50627C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Secondary emotions
        if (result.secondaryEmotions.isNotEmpty) ...[
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('SECONDARY EMOTIONS'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      result.secondaryEmotions
                          .map(
                            (e) => _emotionChip(
                              e[0].toUpperCase() + e.substring(1),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // AI Insight
        if (result.aiInsight != null) ...[
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      size: 15,
                      color: Color(0xFF7D93AD),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI Insight',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF1F2B3B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  result.aiInsight!,
                  style: GoogleFonts.inter(
                    height: 1.5,
                    fontSize: 13,
                    color: const Color(0xFF50627C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // CBT Reframe
        if (result.cbtReframe != null) ...[
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('CBT REFRAME'),
                const SizedBox(height: 8),
                if (result.distortionType != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        result.distortionType!.toUpperCase().replaceAll(
                          '-',
                          ' ',
                        ),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A7E96),
                        ),
                      ),
                    ),
                  ),
                if (result.distortionType != null) const SizedBox(height: 8),
                Text(
                  '"${result.cbtReframe!}"',
                  style: GoogleFonts.inter(
                    height: 1.5,
                    fontSize: 13,
                    color: const Color(0xFF50627C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: child,
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
        color: Color(0xFF697B91),
      ),
    );
  }

  Widget _emotionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Color(0xFF33465F),
        ),
      ),
    );
  }
}
