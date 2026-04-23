import 'package:flutter/material.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class VoiceJournalScreen extends StatefulWidget {
  const VoiceJournalScreen({super.key});

  @override
  State<VoiceJournalScreen> createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends State<VoiceJournalScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedFeeling = 'Peaceful';

  final List<Map<String, dynamic>> _feelings = [
    {
      'label': 'Peaceful',
      'color': const Color(0xFFD6E9F5),
      'textColor': const Color(0xFF5E96BA),
    },
    {
      'label': 'Anxious',
      'color': const Color(0xFFFAE5D4),
      'textColor': const Color(0xFFD5743D),
    },
    {
      'label': 'Energetic',
      'color': const Color(0xFFFBF1D1),
      'textColor': const Color(0xFF8B6C1F),
      'borderColor': const Color(0xFFB19747),
    },
    {
      'label': 'Good',
      'color': const Color(0xFFF7DDF0),
      'textColor': const Color(0xFFC75DAB),
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];

    int hour = now.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;

    final minuteStr = now.minute.toString().padLeft(2, '0');
    final dateString = '$weekday $month ${now.day} $hour:$minuteStr $ampm';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.black54,
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Text Input Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'What is on your mind today?',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 30),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOW ARE YOU FEELING?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feeling Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _feelings.map((feeling) {
                            final isSelected =
                                _selectedFeeling == feeling['label'];
                            final hasBorder = feeling.containsKey(
                              'borderColor',
                            );

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFeeling = feeling['label'];
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: feeling['color'],
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? feeling['textColor']
                                            : (hasBorder
                                                ? feeling['borderColor']
                                                : Colors.transparent),
                                    width: isSelected ? 2 : (hasBorder ? 1 : 0),
                                  ),
                                ),
                                child: Text(
                                  feeling['label'],
                                  style: TextStyle(
                                    color: feeling['textColor'],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.emotionResult);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD3E3F1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Save & Analyze',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Privacy footer
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ENCRYPTED PRIVACY VAULT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 20), // Compensate for right padding
                    ],
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
