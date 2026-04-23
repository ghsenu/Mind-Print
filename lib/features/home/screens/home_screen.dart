import 'package:flutter/material.dart';
import 'package:mind_print/features/chatbot/screens/chatbot_screen.dart';
import 'package:mind_print/features/journal/screens/voice_journal_screen.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMood = 2;

  final List<_MoodItem> _moods = const <_MoodItem>[
    _MoodItem('😞', 'Stressed'),
    _MoodItem('😱', 'Sad'),
    _MoodItem('😐', 'Neutral'),
    _MoodItem('😊', 'Happy'),
    _MoodItem('😍', 'Overjoyed'),
  ];

  void _selectNextMood() {
    setState(() {
      _selectedMood = (_selectedMood + 1) % _moods.length;
    });
  }

  void _selectPreviousMood() {
    setState(() {
      _selectedMood = (_selectedMood - 1 + _moods.length) % _moods.length;
    });
  }

  void _handleMoodSwipe(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity < -100) {
      _selectNextMood();
    } else if (velocity > 100) {
      _selectPreviousMood();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String moodLabel = _moods[_selectedMood].label;
    const Color softBlueIcon = Color(0xFFB9D9EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFFF8FBFF),
                Color(0xFFD9ECF8),
                Color(0xFFB9D9EB),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: <Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFFFDAB9),
                      child: Text('🧑🏽', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Hi, Michael',
                      style: TextStyle(fontSize: 17, color: Color(0xFF374151)),
                    ),
                    const Spacer(),
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: IconButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.notifications,
                            ),
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFFB9D9EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Good Morning!\nHow are you today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: _handleMoodSwipe,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(_moods.length, (int index) {
                      final bool isSelected = index == _selectedMood;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = index;
                          });
                        },
                        child: AnimatedScale(
                          scale: isSelected ? 1.18 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: SizedBox(
                            width: 64,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _moods[index].emoji,
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _moods[index].label,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFB923C),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Predictive Mood Alert',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'A mood dip is predicted for this afternoon. Consider a 5-minute meditation.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'x',
                        style: TextStyle(
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Text(
                            "Today's Insight",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9FCEB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '94% Confidence',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your morning check-in, your dominant emotion is',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        moodLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Explore Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _CategoryCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Journal',
                        isSelected: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VoiceJournalScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CategoryCard(
                        icon: Icons.auto_graph_outlined,
                        title: 'Activities',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.coping);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _CategoryCard(
                        icon: Icons.bar_chart_rounded,
                        title: 'Analytics',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.analytics);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CategoryCard(
                        icon: Icons.picture_as_pdf_outlined,
                        title: 'Fingerprint\nReport',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.reports);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _BottomItem(Icons.home_outlined, 'Home', selected: true),
                    const _BottomItem(
                      Icons.notifications_none,
                      'Notifications',
                      onTapRoute: AppRoutes.notifications,
                      unselectedColor: softBlueIcon,
                    ),
                    const _CenterStar(),
                    const _BottomItem(
                      Icons.person_outline,
                      'Profile',
                      unselectedColor: softBlueIcon,
                    ),
                    const _BottomItem(
                      Icons.settings_outlined,
                      'Settings',
                      unselectedColor: softBlueIcon,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF2490E8) : const Color(0xFFBFD0DC),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0x22000000),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD5DEE6)),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF1E2940),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.1,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A2238),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodItem {
  const _MoodItem(this.emoji, this.label);

  final String emoji;
  final String label;
}

class _BottomItem extends StatelessWidget {
  const _BottomItem(
    this.icon,
    this.label, {
    this.selected = false,
    this.onTapRoute,
    this.unselectedColor = const Color(0xFF6B7280),
  });

  final IconData icon;
  final String label;
  final bool selected;
  final String? onTapRoute;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onTapRoute == null
              ? null
              : () => Navigator.pushNamed(context, onTapRoute!),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: selected ? const Color(0xFF0EA5E9) : unselectedColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? const Color(0xFF0EA5E9) : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterStar extends StatelessWidget {
  const _CenterStar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatBotScreen()),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFFEC4899),
              Color(0xFF6366F1),
              Color(0xFF06B6D4),
            ],
          ),
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
      ),
    );
  }
}
