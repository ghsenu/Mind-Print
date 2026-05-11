import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/core/database/firestore_database.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/profile/services/profile_service.dart';
import 'package:mind_print/features/shared/models/user_profile.dart';

final firestoreDatabaseProvider = Provider<FirestoreDatabase>(
  (_) => FirestoreDatabase(),
);

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(firestoreDatabaseProvider));
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(profileServiceProvider).watchProfile(user.uid);
});
