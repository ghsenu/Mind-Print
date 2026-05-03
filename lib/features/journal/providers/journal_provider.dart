import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/core/config/env.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/journal/services/hugging_face_service.dart';
import 'package:mind_print/features/journal/services/journal_service.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';
import 'package:mind_print/features/shared/providers/user_profile_provider.dart';

final huggingFaceServiceProvider = Provider<HuggingFaceService>((ref) {
  return HuggingFaceService(Env.hfApiKey);
});

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(
    ref.watch(firestoreDatabaseProvider),
    ref.watch(huggingFaceServiceProvider),
  );
});

final journalsProvider = StreamProvider<List<JournalEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(journalServiceProvider).watchJournals(user.uid);
});
