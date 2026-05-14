import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/features/analytics/services/analytics_service.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/home/services/mood_checkin_service.dart';
import 'package:mind_print/features/shared/models/mood_checkin.dart';
import 'package:mind_print/features/shared/models/prediction.dart';
import 'package:mind_print/features/shared/providers/user_profile_provider.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(firestoreDatabaseProvider));
});

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return AnalyticsSummary.empty();
  return ref.read(analyticsServiceProvider).getAnalyticsSummary(user.uid);
});

final latestPredictionProvider = FutureProvider<Prediction?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(analyticsServiceProvider).getLatestPrediction(user.uid);
});

final moodCheckinServiceProvider = Provider<MoodCheckinService>((ref) {
  return MoodCheckinService(ref.watch(firestoreDatabaseProvider));
});

final latestMoodCheckinProvider = FutureProvider<MoodCheckin?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(moodCheckinServiceProvider).getLatestCheckin(user.uid);
});
