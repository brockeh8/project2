import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_session.dart';

class SessionService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<StudySession> startSession(String groupId, int minutes) async {
    final uid = _auth.currentUser!.uid;
    final doc = _db.collection('sessions').doc();

    final s = StudySession(
      id: doc.id,
      groupId: groupId,
      createdByUid: uid,
      startTime: DateTime.now(),
      durationMinutes: minutes,
      isActive: true,
    );

    await doc.set(s.toMap());
    return s;
  }

  Future<void> endSession(String sessionId) async {
    await _db
        .collection('sessions')
        .doc(sessionId)
        .update({'isActive': false});
  }
}
