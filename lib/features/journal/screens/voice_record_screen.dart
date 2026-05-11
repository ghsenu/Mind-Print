import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/journal/providers/journal_provider.dart';
import 'package:mind_print/features/journal/screens/emotion_result_screen.dart';

enum _RecordState { idle, recording, processing }

class VoiceRecordScreen extends ConsumerStatefulWidget {
  const VoiceRecordScreen({super.key});

  @override
  ConsumerState<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends ConsumerState<VoiceRecordScreen> {
  _RecordState _state = _RecordState.idle;
  String _processingLabel = '';
  String _selectedFeeling = 'Peaceful';
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _errorMessage;

  static const Map<String, int> _feelingScores = {
    'Peaceful': 4,
    'Anxious': 2,
    'Energetic': 5,
    'Good': 4,
  };

  static const List<Map<String, dynamic>> _feelings = [
    {
      'label': 'Peaceful',
      'color': Color(0xFFD6E9F5),
      'textColor': Color(0xFF5E96BA),
    },
    {
      'label': 'Anxious',
      'color': Color(0xFFFAE5D4),
      'textColor': Color(0xFFD5743D),
    },
    {
      'label': 'Energetic',
      'color': Color(0xFFFBF1D1),
      'textColor': Color(0xFF8B6C1F),
    },
    {
      'label': 'Good',
      'color': Color(0xFFF7DDF0),
      'textColor': Color(0xFFC75DAB),
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    final voiceService = ref.read(voiceServiceProvider);
    voiceService.isRecording
        .then((recording) {
          if (recording) {
            voiceService.stopRecording().catchError((e) {
              debugPrint('Failed to stop recorder during dispose: $e');
            });
          }
        })
        .catchError((e) {
          debugPrint('Failed to check recorder state during dispose: $e');
        });
    super.dispose();
  }

  String get _timerLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onMicTap() async {
    if (_state == _RecordState.idle) {
      await _startRecording();
    } else if (_state == _RecordState.recording) {
      await _stopAndProcess();
    }
  }

  Future<void> _startRecording() async {
    final voiceService = ref.read(voiceServiceProvider);
    final granted = await voiceService.requestMicPermission();
    if (!granted) {
      if (mounted) {
        setState(
          () =>
              _errorMessage =
                  'Microphone permission denied. Please enable it in Settings.',
        );
      }
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await voiceService.startRecording(filePath);
    if (mounted) {
      setState(() {
        _state = _RecordState.recording;
        _errorMessage = null;
      });
      _startTimer();
    }
  }

  Future<void> _stopAndProcess() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _errorMessage = 'You must be signed in.');
      return;
    }

    _stopTimer();
    setState(() {
      _state = _RecordState.processing;
      _processingLabel = 'Stopping...';
    });

    final voiceService = ref.read(voiceServiceProvider);
    final assemblyAi = ref.read(assemblyAiServiceProvider);
    final journalService = ref.read(journalServiceProvider);
    String? localPath;

    try {
      localPath = await voiceService.stopRecording();

      setState(() => _processingLabel = 'Uploading audio...');
      final transcript = await assemblyAi.transcribeFile(
        localPath,
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'transcribing') {
            setState(() => _processingLabel = 'Transcribing...');
          }
        },
      );

      setState(() => _processingLabel = 'Analyzing emotions...');
      final moodScore = _feelingScores[_selectedFeeling] ?? 3;
      final result = await journalService.analyzeVoiceEntry(
        user.uid,
        transcript,
        moodScore,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmotionResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _RecordState.idle;
          _elapsedSeconds = 0;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (localPath != null) {
        File(localPath).delete().catchError((e) {
          debugPrint('Failed to delete temp voice file: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
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
    const weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    final dateString =
        '${weekdays[now.weekday - 1]} ${months[now.month - 1]} ${now.day}';

    final isProcessing = _state == _RecordState.processing;
    final isRecording = _state == _RecordState.recording;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                    onPressed:
                        isProcessing ? null : () => Navigator.pop(context),
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

            // Recording area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isProcessing
                          ? _processingLabel
                          : isRecording
                          ? 'Recording...'
                          : 'Tap to Record',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            isRecording
                                ? const Color(0xFFD5473D)
                                : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Mic / stop button
                    GestureDetector(
                      onTap: isProcessing ? null : _onMicTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isProcessing
                                  ? const Color(0xFFE5E7EB)
                                  : isRecording
                                  ? const Color(0xFFD5473D)
                                  : const Color(0xFFD3E3F1),
                          boxShadow: [
                            BoxShadow(
                              color: (isRecording
                                      ? const Color(0xFFD5473D)
                                      : const Color(0xFF89A8C8))
                                  .withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child:
                            isProcessing
                                ? const Center(
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Color(0xFF89A8C8),
                                    ),
                                  ),
                                )
                                : Icon(
                                  isRecording ? Icons.stop : Icons.mic,
                                  size: 52,
                                  color:
                                      isRecording
                                          ? Colors.white
                                          : const Color(0xFF4A7FA5),
                                ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Timer
                    Text(
                      _timerLabel,
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        color:
                            isRecording
                                ? const Color(0xFF374151)
                                : const Color(0xFFD1D5DB),
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom: mood chips + privacy footer
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _feelings.map((feeling) {
                            final isSelected =
                                _selectedFeeling == feeling['label'];
                            return GestureDetector(
                              onTap:
                                  isProcessing
                                      ? null
                                      : () => setState(
                                        () =>
                                            _selectedFeeling =
                                                feeling['label'] as String,
                                      ),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: feeling['color'] as Color,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? feeling['textColor'] as Color
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  feeling['label'] as String,
                                  style: TextStyle(
                                    color: feeling['textColor'] as Color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
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
