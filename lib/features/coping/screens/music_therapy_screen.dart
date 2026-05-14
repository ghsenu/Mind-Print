import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/activity_models.dart';
import '../widgets/music_player.dart';

class MusicTherapyScreen extends StatelessWidget {
  const MusicTherapyScreen({super.key});

  // TODO: Replace each audioUrl with the Firebase Storage download URL after
  // uploading the files. Run MusicStorageService.printAllUrls() once to get them.
  static const List<MusicTrack> _playlist = [
    MusicTrack(
      title: 'Ocean Calm',
      duration: '04:20',
      moodTag: 'ANXIOUS',
      moodColor: Color(0xFF6ACFEF),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    ),
    MusicTrack(
      title: 'Forest Rain',
      duration: '06:45',
      moodTag: 'STRESSED',
      moodColor: Color(0xFF22C55E),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    ),
    MusicTrack(
      title: 'Zen Focus',
      duration: '08:00',
      moodTag: 'RESTLESS',
      moodColor: Color(0xFFA855F7),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ),
    MusicTrack(
      title: 'Deep Sleep',
      duration: '15:00',
      moodTag: 'INSOMNIA',
      moodColor: Color(0xFF0EA5E9),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    ),
    MusicTrack(
      title: 'Morning Light',
      duration: '05:30',
      moodTag: 'SAD',
      moodColor: Color(0xFFEAB308),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    ),
    MusicTrack(
      title: 'Gentle Flow',
      duration: '07:15',
      moodTag: 'TENSE',
      moodColor: Color(0xFFF97316),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    ),
    MusicTrack(
      title: 'Soft Horizon',
      duration: '09:00',
      moodTag: 'OVERWHELMED',
      moodColor: Color(0xFFEC4899),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
    ),
    MusicTrack(
      title: 'Still Waters',
      duration: '11:20',
      moodTag: 'ANXIOUS',
      moodColor: Color(0xFF6ACFEF),
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
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
                      'Music Therapy',
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
                  'Emotion-matched audio for every feeling',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Mood filter chips ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'All',
                          'Anxious',
                          'Stressed',
                          'Sad',
                          'Restless',
                        ].asMap().entries.map((e) {
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  e.key == 0
                                      ? const Color(0xFF6ACFEF)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              e.value,
                              style: GoogleFonts.lora(
                                fontSize: 13,
                                fontWeight:
                                    e.key == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    e.key == 0
                                        ? Colors.white
                                        : const Color(0xFF6B6B8A),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'SESSION PLAYLIST',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const Color(0xFF6B6B8A).withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Track list ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      _playlist.asMap().entries.map((e) {
                        return _TrackRow(
                          track: e.value,
                          index: e.key,
                          playlist: _playlist,
                        );
                      }).toList(),
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

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.index,
    required this.playlist,
  });

  final MusicTrack track;
  final int index;
  final List<MusicTrack> playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: track.moodColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.music_note_rounded,
                color: track.moodColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  track.duration,
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: const Color(0xFF6B6B8A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: track.moodColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    track.moodTag,
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: track.moodColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // More + Play
          Column(
            children: [
              const Icon(Icons.more_horiz, color: Color(0xFF6B6B8A), size: 20),
              const SizedBox(height: 8),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MusicPlayerScreen(
                              track: track,
                              playlist: playlist,
                              initialIndex: index,
                            ),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: track.moodColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Play',
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
