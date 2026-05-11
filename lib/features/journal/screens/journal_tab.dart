import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/journal/providers/journal_provider.dart';
import 'package:mind_print/features/journal/screens/journal_detail_screen.dart';
import 'package:mind_print/features/journal/screens/voice_journal_screen.dart';
import 'package:mind_print/features/journal/screens/voice_record_screen.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';
import 'package:mind_print/features/shared/widgets/custom_bottom_nav.dart';

class JournalTab extends ConsumerStatefulWidget {
  const JournalTab({super.key});

  @override
  ConsumerState<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<JournalTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<JournalEntry> _allEntries = [];

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

  // Mood score → display data
  static const Map<int, Map<String, dynamic>> _moodMeta = {
    1: {
      'label': 'STRESSED',
      'moodColor': Color(0xFFFAE5D4),
      'moodTextColor': Color(0xFFD5743D),
      'iconBg': Color(0xFFFAE5D4),
      'iconColor': Color(0xFFD5743D),
    },
    2: {
      'label': 'SAD',
      'moodColor': Color(0xFFE6F0FF),
      'moodTextColor': Color(0xFF0056D2),
      'iconBg': Color(0xFFE6F0FF),
      'iconColor': Color(0xFF0056D2),
    },
    3: {
      'label': 'NEUTRAL',
      'moodColor': Color(0xFFF3E8FF),
      'moodTextColor': Color(0xFF7E22CE),
      'iconBg': Color(0xFFF3E8FF),
      'iconColor': Color(0xFF7E22CE),
    },
    4: {
      'label': 'CALM',
      'moodColor': Color(0xFFE4F8EA),
      'moodTextColor': Color(0xFF28A745),
      'iconBg': Color(0xFFE4F8EA),
      'iconColor': Color(0xFF28A745),
    },
    5: {
      'label': 'JOYFUL',
      'moodColor': Color(0xFFFDF0CF),
      'moodTextColor': Color(0xFFF25A12),
      'iconBg': Color(0xFFFDECE4),
      'iconColor': Color(0xFFF25A12),
    },
  };

  static const Map<int, IconData> _moodIcons = {
    1: Icons.sentiment_very_dissatisfied,
    2: Icons.sentiment_dissatisfied,
    3: Icons.sentiment_neutral,
    4: Icons.sentiment_satisfied_alt,
    5: Icons.sentiment_very_satisfied,
  };

  String _formatDate(DateTime dt) {
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final journalsAsync = ref.watch(journalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            onPressed:
                () => showSearch(
                  context: context,
                  delegate: _JournalSearchDelegate(_allEntries),
                ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1.5),
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
                borderSide: BorderSide(color: Color(0xFFF25A12), width: 2.5),
              ),
              tabs: const [
                Tab(text: 'Text Journal'),
                Tab(text: 'Voice Journal'),
              ],
            ),
          ),
          Expanded(
            child: journalsAsync.when(
              loading:
                  () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF25A12)),
                  ),
              error:
                  (e, _) => Center(
                    child: Text(
                      'Could not load entries.\n$e',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8A93A6),
                        fontSize: 14,
                      ),
                    ),
                  ),
              data: (entries) {
                // Cache for search delegate.
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => setState(() => _allEntries = entries),
                );

                final textEntries =
                    entries.where((e) => e.entryType == 'text').toList();
                final voiceEntries =
                    entries.where((e) => e.entryType == 'voice').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildJournalList(textEntries),
                    _buildJournalList(voiceEntries),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF25A12),
        onPressed: () => _showEntryTypeSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: -1),
    );
  }

  Widget _buildJournalList(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.book_outlined, size: 48, color: Color(0xFFCDD5E0)),
            const SizedBox(height: 12),
            Text(
              'No entries yet.\nTap + to write your first.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF8A93A6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

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
              Text(
                '${entries.length} total',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF8A93A6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...entries.map((entry) => _buildJournalCard(entry)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    final meta = _moodMeta[entry.moodScore] ?? _moodMeta[3]!;
    final icon = _moodIcons[entry.moodScore] ?? Icons.sentiment_neutral;
    final isVoice = entry.entryType == 'voice';

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalDetailScreen(entry: entry),
            ),
          ),
      child: Container(
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: meta['iconBg'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: meta['iconColor'] as Color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(entry.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E212C),
                        ),
                      ),
                      Icon(
                        isVoice ? Icons.mic_none : Icons.edit_note,
                        size: 18,
                        color: const Color(0xFF8A93A6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(
                        meta['label'] as String,
                        meta['moodColor'] as Color,
                        meta['moodTextColor'] as Color,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        isVoice ? 'VOICE' : 'TEXT',
                        const Color(0xFFFDECE4),
                        const Color(0xFFF25A12),
                      ),
                      if (entry.isAnalyzed) ...[
                        const SizedBox(width: 8),
                        _buildChip(
                          'ANALYZED',
                          const Color(0xFFE4F8EA),
                          const Color(0xFF28A745),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.content.isNotEmpty ? entry.content : 'Voice entry',
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

  void _showEntryTypeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetCtx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Journal Entry',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SheetOption(
                    icon: Icons.edit_note,
                    title: 'Text Entry',
                    subtitle: 'Write about how you feel',
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoiceJournalScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _SheetOption(
                    icon: Icons.mic,
                    title: 'Voice Entry',
                    subtitle: 'Speak and let AI transcribe',
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoiceRecordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ─── Search Delegate ──────────────────────────────────────────────────────────

class _JournalSearchDelegate extends SearchDelegate<JournalEntry?> {
  _JournalSearchDelegate(this._entries);

  final List<JournalEntry> _entries;

  @override
  String get searchFieldLabel => 'Search journal entries...';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  List<JournalEntry> get _filtered =>
      _entries
          .where((e) => e.content.toLowerCase().contains(query.toLowerCase()))
          .toList();

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Type to search your entries',
          style: GoogleFonts.inter(color: const Color(0xFF8A93A6)),
        ),
      );
    }

    final results = _filtered;
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No entries matching "$query"',
          style: GoogleFonts.inter(color: const Color(0xFF8A93A6)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final entry = results[i];
        final isVoice = entry.entryType == 'voice';
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            isVoice ? Icons.mic_none : Icons.edit_note,
            color: const Color(0xFF89A8C8),
          ),
          title: Text(
            entry.content.isNotEmpty ? entry.content : 'Voice entry',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF374151),
            ),
          ),
          subtitle: Text(
            '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF8A93A6),
            ),
          ),
          onTap: () {
            close(context, entry);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JournalDetailScreen(entry: entry),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Sheet Option Widget ──────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E3F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF4A7FA5), size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A93A6),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF8A93A6),
            ),
          ],
        ),
      ),
    );
  }
}
