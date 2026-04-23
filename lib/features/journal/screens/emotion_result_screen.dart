import 'package:flutter/material.dart';

class EmotionResultScreen extends StatelessWidget {
  const EmotionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    _buildEmotionHero(),
                    const SizedBox(height: 18),
                    _buildSecondaryEmotions(),
                    const SizedBox(height: 18),
                    _buildAiInsightCard(),
                    const SizedBox(height: 14),
                    _buildCbtCard(),
                  ],
                ),
              ),
            ),
            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionHero() {
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
          child: const Center(
            child: Text('😌', style: TextStyle(fontSize: 38)),
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
            'MULTIMODAL ANALYSIS',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E8BAA),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Joyful',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFF162033),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '85% Confidence Score',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF50627C),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryEmotions() {
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
            children: const <Widget>[
              _EmotionChip(label: 'Calm', score: '12%'),
              _EmotionChip(label: 'Surprise', score: '3%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
          SizedBox(height: 10),
          Text(
            'Based on your vocal tone and heart rate variance, your joy appears to be rooted in a sense of relief. The subtle calming markers suggest that a recent stressor has been successfully navigated.',
            style: TextStyle(
              height: 1.45,
              fontSize: 13,
              color: Color(0xFF50627C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCbtCard() {
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
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '"I\'m just lucky"',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2B3B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DISCOUNTING POSITIVES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A7E96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '"You acknowledge your effort in this outcome. You didn\'t just stumble into this success; your persistence played a key role."',
            style: TextStyle(
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

  Widget _buildBottomArea() {
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
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                  label: const Text('Save to Journal'),
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
              const SizedBox(height: 10),
              const _MiniBottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({required this.label, required this.score});

  final String label;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF33465F),
              ),
            ),
            TextSpan(
              text: score,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8CA0B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBottomNav extends StatelessWidget {
  const _MiniBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _NavItem(icon: Icons.home_outlined, label: 'Home'),
          _NavItem(
            icon: Icons.auto_graph_outlined,
            label: 'Analysis',
            active: true,
          ),
          _NavItem(icon: Icons.menu_book_outlined, label: 'Journal'),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color =
        active ? const Color(0xFF7697B8) : const Color(0xFF8FA0B4);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
