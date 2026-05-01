import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/widgets/custom_bottom_nav.dart';
import 'voice_journal_screen.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _entries = [
    {
      'date': 'October 24, 2023',
      'mood': 'CALM',
      'moodColor': const Color(0xFFE4F8EA),
      'moodTextColor': const Color(0xFF28A745),
      'type': 'TEXT',
      'typeColor': const Color(0xFFFDECE4),
      'typeTextColor': const Color(0xFFF25A12),
      'text': 'Feeling much more centered after the...',
      'icon': Icons.sentiment_satisfied_alt,
      'iconBg': const Color(0xFFFDECE4),
      'iconColor': const Color(0xFFF25A12),
      'isVoice': false,
    },
    {
      'date': 'October 23, 2023',
      'mood': 'REFLECTIVE',
      'moodColor': const Color(0xFFE6F0FF),
      'moodTextColor': const Color(0xFF0056D2),
      'type': 'VOICE',
      'typeColor': const Color(0xFFFEEFEB),
      'typeTextColor': const Color(0xFFF25A12),
      'text': 'Recorded some thoughts about the...',
      'icon': Icons.sentiment_neutral,
      'iconBg': const Color(0xFFE6F0FF),
      'iconColor': const Color(0xFF0056D2),
      'isVoice': true,
    },
    {
      'date': 'October 22, 2023',
      'mood': 'ANXIOUS',
      'moodColor': const Color(0xFFFDF0CF),
      'moodTextColor': const Color(0xFFE88E0E),
      'type': 'TEXT',
      'typeColor': const Color(0xFFFDECE4),
      'typeTextColor': const Color(0xFFF25A12),
      'text': 'Struggling to stay focused today with...',
      'icon': Icons.sentiment_very_dissatisfied,
      'iconBg': const Color(0xFFFDF0CF),
      'iconColor': const Color(0xFFF25A12),
      'isVoice': false,
    },
    {
      'date': 'October 21, 2023',
      'mood': 'JOYFUL',
      'moodColor': const Color(0xFFFDF0CF),
      'moodTextColor': const Color(0xFFF25A12),
      'type': 'TEXT',
      'typeColor': const Color(0xFFFDECE4),
      'typeTextColor': const Color(0xFFF25A12),
      'text': 'Had a breakthrough in therapy today....',
      'icon': Icons.sentiment_very_satisfied,
      'iconBg': const Color(0xFFFDECE4),
      'iconColor': const Color(0xFFF25A12),
      'isVoice': false,
    },
    {
      'date': 'October 20, 2023',
      'mood': 'INSPIRED',
      'moodColor': const Color(0xFFF3E8FF),
      'moodTextColor': const Color(0xFF7E22CE),
      'type': 'VOICE',
      'typeColor': const Color(0xFFFEEFEB),
      'typeTextColor': const Color(0xFFF25A12),
      'text': 'New project starting! Lots of idea...',
      'icon': Icons.sentiment_very_satisfied,
      'iconBg': const Color(0xFFF3E8FF),
      'iconColor': const Color(0xFF7E22CE),
      'isVoice': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false, // In case it's top-level or you want it flat
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFF25A12),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Journal',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A2E),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1A1A2E), size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Custom TabBar to match exactly the design
          Container(
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEAEAEA),
                  width: 1.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFF25A12),
              unselectedLabelColor: const Color(0xFF8A93A6),
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Color(0xFFF25A12),
                  width: 2.5,
                ),
              ),
              tabs: const [
                Tab(text: 'Text Journal'),
                Tab(text: 'Voice Journal'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJournalList(),
                _buildJournalList(), // Showing same content for voice as placeholder
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF25A12),
        onPressed: () {
          // Navigate to Write Journal Screen. Currently routing to VoiceJournalScreen.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VoiceJournalScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: -1), // No selection, just shown
    );
  }

  Widget _buildJournalList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Entries',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E212C),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF25A12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._entries.map((entry) => _buildJournalCard(entry)),
          const SizedBox(height: 30), // Padding above bottom nav/FAB
        ],
      ),
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: entry['iconBg'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entry['icon'],
              color: entry['iconColor'],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry['date'],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E212C),
                      ),
                    ),
                    Icon(
                      entry['isVoice'] ? Icons.mic_none : Icons.edit_note,
                      size: 18,
                      color: const Color(0xFF8A93A6),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildChip(entry['mood'], entry['moodColor'], entry['moodTextColor']),
                    const SizedBox(width: 8),
                    _buildChip(entry['type'], entry['typeColor'], entry['typeTextColor']),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry['text'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF8A93A6),
                    fontWeight: FontWeight.w500,
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
  }

  Widget _buildChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
