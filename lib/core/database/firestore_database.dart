import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  FirestoreDatabase({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> journals(String userId) {
    return _firestore.collection('users').doc(userId).collection('journals');
  }

  CollectionReference<Map<String, dynamic>> moodCheckins(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('moodCheckins');
  }

  CollectionReference<Map<String, dynamic>> predictions(String userId) {
    return _firestore.collection('users').doc(userId).collection('predictions');
  }

  CollectionReference<Map<String, dynamic>> notifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  CollectionReference<Map<String, dynamic>> reports(String userId) {
    return _firestore.collection('users').doc(userId).collection('reports');
  }

  Future<void> setNetworkEnabled(bool enabled) async {
    if (enabled) {
      await _firestore.enableNetwork();
    } else {
      await _firestore.disableNetwork();
    }
  }
}
