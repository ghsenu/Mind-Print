import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_print/core/database/firestore_database.dart';
import 'package:mind_print/features/shared/models/user_profile.dart';

class ProfileService {
  ProfileService(this._db);

  final FirestoreDatabase _db;

  Stream<UserProfile?> watchProfile(String userId) {
    return _db.userDoc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromFirestore(snap);
    });
  }

  Future<UserProfile?> getProfile(String userId) async {
    final snap = await _db.userDoc(userId).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromFirestore(snap);
  }

  Future<void> saveProfile(UserProfile profile) {
    return _db.userDoc(profile.userId).set(profile.toFirestore());
  }

  Future<void> updateFields(String userId, Map<String, dynamic> fields) {
    return _db.userDoc(userId).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> findEmailByUsername(String username) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['email'] as String?;
  }

  Future<void> createInitialProfile(
    String userId,
    String email, {
    String displayName = '',
  }) async {
    final existing = await getProfile(userId);
    if (existing != null) return;
    final profile = UserProfile.initial(
      userId,
      email,
      displayName: displayName,
    );
    await saveProfile(profile);
  }
}
