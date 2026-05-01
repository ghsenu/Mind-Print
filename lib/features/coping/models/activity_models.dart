import 'package:flutter/material.dart';

class ActivityCategory {
  const ActivityCategory({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.route,
    required this.count,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final String route;
  final String count;
}

class BreathingExercise {
  const BreathingExercise({
    required this.name,
    required this.description,
    required this.inhaleSecs,
    required this.holdSecs,
    required this.exhaleSecs,
    required this.durationMinutes,
    required this.color,
  });

  final String name;
  final String description;
  final int inhaleSecs;
  final int holdSecs;
  final int exhaleSecs;
  final int durationMinutes;
  final Color color;

  int get cycleSecs => inhaleSecs + holdSecs + exhaleSecs;
}

class MusicTrack {
  const MusicTrack({
    required this.title,
    required this.duration,
    required this.moodTag,
    required this.moodColor,
    this.audioUrl,
  });

  final String title;
  final String duration;
  final String moodTag;
  final Color moodColor;
  final String? audioUrl;
}

class MeditationSession {
  const MeditationSession({
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.color,
  });

  final String title;
  final String description;
  final int durationMinutes;
  final Color color;
}

class CbtExercise {
  const CbtExercise({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.steps,
  });

  final String title;
  final String description;
  final String emoji;
  final Color color;
  final List<String> steps;
}
