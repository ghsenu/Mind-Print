import 'package:flutter/material.dart';
import 'package:mind_print/features/shared/models/emotion_result.dart';

class EmotionResultScreen extends StatelessWidget {
  const EmotionResultScreen({super.key, required this.result});

  final EmotionResult result;

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
  Widget build(BuildContext context) {
    final emoji = _emotionEmoji[result.primaryEmotion] ?? '😐';
    final emotionLabel =
        result.primaryEmotion[0].toUpperCase() +
        result.primaryEmotion.substring(1);
    final confidencePct = (result.intensity * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: const Color(0xFFF3F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: <Widget>[
                    _buildEmotionHero(emoji, emotionLabel, confidencePct),
                    if (result.secondaryEmotions.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _buildSecondaryEmotions(result.secondaryEmotions),
                    ],
                    if (result.aiInsight != null) ...[
                      const SizedBox(height: 18),
                      _buildAiInsightCard(result.aiInsight!),
                    ],
                    if (result.cbtReframe != null) ...[
                      const SizedBox(height: 14),
                      _buildCbtCard(result.cbtReframe!, result.distortionType),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionHero(
    String emoji,
    String emotionLabel,
    int confidencePct,
  ) {
    return Column(
      children: <Widget>[
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF88A6C5), width: 7),
            color: Colors.white,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 38)),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'AI ANALYSIS',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E8BAA),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          emotionLabel,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFF162033),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$confidencePct% Confidence Score',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF50627C),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryEmotions(List<String> emotions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'SECONDARY EMOTIONS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: Color(0xFF697B91),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                emotions
                    .map(
                      (e) => _EmotionChip(
                        label: e[0].toUpperCase() + e.substring(1),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(String insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.auto_awesome_outlined,
                size: 16,
                color: Color(0xFF7D93AD),
              ),
              SizedBox(width: 6),
              Text(
                'AI Insight',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1F2B3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight,
            style: const TextStyle(
              height: 1.45,
              fontSize: 13,
              color: Color(0xFF50627C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCbtCard(String reframe, String? distortionType) {
    final distortionLabel = distortionType?.toUpperCase().replaceAll('-', ' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'CBT REFRAME',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: Color(0xFF697B91),
            ),
          ),
          const SizedBox(height: 8),
          if (distortionLabel != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  distortionLabel,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A7E96),
                  ),
                ),
              ),
            ),
          if (distortionLabel != null) const SizedBox(height: 8),
          Text(
            '"$reframe"',
            style: const TextStyle(
              height: 1.45,
              fontSize: 13,
              color: Color(0xFF50627C),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Was this helpful?',
            style: TextStyle(fontSize: 11, color: Color(0xFF7F8FA3)),
          ),
          const SizedBox(height: 8),
          const Row(
            children: <Widget>[
              Icon(
                Icons.thumb_up_alt_outlined,
                size: 18,
                color: Color(0xFF91A3B8),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.thumb_down_alt_outlined,
                size: 18,
                color: Color(0xFF91A3B8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F6FA),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      () => Navigator.of(context).popUntil((r) => r.isFirst),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF89A8C8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FA),
        borderRadius: BorderRadius.circular(16),
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
