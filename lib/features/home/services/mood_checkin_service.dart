import 'package:mind_print/core/database/firestore_database.dart';
import 'package:mind_print/features/shared/models/mood_checkin.dart';

class MoodCheckinService {
  MoodCheckinService(this._db);

  final FirestoreDatabase _db;

  Future<void> saveMoodCheckin(String userId, int score, String label) async {
    final ref = _db.moodCheckins(userId).doc();
    final checkin = MoodCheckin(
      id: ref.id,
      userId: userId,
      score: score,
      label: label,
      createdAt: DateTime.now(),
    );
    await ref.set(checkin.toFirestore());
  }
}
