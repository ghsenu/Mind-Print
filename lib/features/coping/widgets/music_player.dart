import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_models.dart';
import '../services/audio_service.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({
    super.key,
    required this.track,
    required this.playlist,
    this.initialIndex = 0,
  });

  final MusicTrack track;
  final List<MusicTrack> playlist;
  final int initialIndex;

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  bool _isPlaying = false;
  bool _playlistExpanded = true;

  late AnimationController _albumPulse;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _albumPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadTrack();
  }

  void _loadTrack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).stop();
      final audioUrl =
          _current.audioUrl ??
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3';
      ref.read(audioServiceProvider).loadAudio(audioUrl).then((_) {
        if (_isPlaying) {
          ref.read(audioServiceProvider).play();
        }
      });
    });
  }

  @override
  void dispose() {
    _albumPulse.dispose();
    ref.read(audioServiceProvider).stop();
    super.dispose();
  }

  MusicTrack get _current => widget.playlist[_currentIndex];

  void _playPause() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      ref.read(audioServiceProvider).play();
    } else {
      ref.read(audioServiceProvider).pause();
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadTrack();
    }
  }

  void _next() {
    if (_currentIndex < widget.playlist.length - 1) {
      setState(() => _currentIndex++);
      _loadTrack();
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = duration.inMinutes.toString();
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioServiceProvider).player;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Now Playing',
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Album Art ────────────────────────────────────────────
            AnimatedBuilder(
              animation: _albumPulse,
              builder: (context, _) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: _current.moodColor.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: _current.moodColor.withValues(
                          alpha: 0.15 + _albumPulse.value * 0.2,
                        ),
                        blurRadius: 40 + _albumPulse.value * 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🎵',
                      style: TextStyle(fontSize: 64 + _albumPulse.value * 8),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Track info ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _current.title,
                          style: GoogleFonts.lora(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _current.duration,
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _current.moodColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _current.moodTag,
                      style: GoogleFonts.lora(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _current.moodColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Seek bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration =
                          player.duration ?? const Duration(seconds: 1);
                      double seekValue =
                          position.inMilliseconds / duration.inMilliseconds;
                      if (seekValue < 0.0) seekValue = 0.0;
                      if (seekValue > 1.0) seekValue = 1.0;

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _current.moodColor,
                              inactiveTrackColor: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              trackHeight: 3,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: seekValue,
                              onChanged: (v) {
                                final seekTo = Duration(
                                  milliseconds:
                                      (v * duration.inMilliseconds).round(),
                                );
                                player.seek(seekTo);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: GoogleFonts.lora(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  _formatDuration(player.duration),
                                  style: GoogleFonts.lora(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Playback controls ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 32,
                  onTap: _prev,
                  enabled: _currentIndex > 0,
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _playPause,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current.moodColor,
                      boxShadow: [
                        BoxShadow(
                          color: _current.moodColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: StreamBuilder<bool>(
                      stream: player.playingStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                _ControlButton(
                  icon: Icons.skip_next_rounded,
                  size: 32,
                  onTap: _next,
                  enabled: _currentIndex < widget.playlist.length - 1,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Session Playlist ─────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap:
                          () => setState(
                            () => _playlistExpanded = !_playlistExpanded,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Text(
                              'Session Playlist',
                              style: GoogleFonts.lora(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _playlistExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_up_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_playlistExpanded)
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.playlist.length,
                          itemBuilder: (context, index) {
                            final t = widget.playlist[index];
                            final isActive = index == _currentIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _currentIndex = index);
                                _loadTrack();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isActive
                                          ? t.moodColor.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: t.moodColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isActive && _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color:
                                            isActive
                                                ? t.moodColor
                                                : Colors.white.withValues(
                                                  alpha: 0.4,
                                                ),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: GoogleFonts.lora(
                                              fontSize: 13,
                                              fontWeight:
                                                  isActive
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color:
                                                  isActive
                                                      ? Colors.white
                                                      : Colors.white.withValues(
                                                        alpha: 0.7,
                                                      ),
                                            ),
                                          ),
                                          Text(
                                            t.duration,
                                            style: GoogleFonts.lora(
                                              fontSize: 11,
                                              color: Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.moodColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        t.moodTag,
                                        style: GoogleFonts.lora(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: t.moodColor,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
        size: size,
      ),
    );
  }
}
