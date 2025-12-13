import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_session.dart';

class SessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<StudySession> scheduleSession({
    required String groupId,
    String? roomId,
    required String title,
    required DateTime startTime,
    int durationMinutes = 25,
  }) async {
    final doc = _db.collection('sessions').doc();
    final session = StudySession(
      id: doc.id,
      groupId: groupId,
      roomId: roomId,
      title: title,
      startTime: startTime,
      durationMinutes: durationMinutes,
      status: 'scheduled',
      createdByUid: _auth.currentUser!.uid,
    );
    await doc.set(session.toMap());
    return session;
  }

  
  Future<StudySession> startSessionNow({
    required String groupId,
    String? roomId,
    required String title,
    int durationMinutes = 25,
  }) async {
    final now = DateTime.now();
    final doc = _db.collection('sessions').doc();
    final session = StudySession(
      id: doc.id,
      groupId: groupId,
      roomId: roomId,
      title: title,
      startTime: now,
      durationMinutes: durationMinutes,
      status: 'active',
      createdByUid: _auth.currentUser!.uid,
    );

    final batch = _db.batch();
    batch.set(doc, session.toMap());

    if (roomId != null) {
      final until = now.add(Duration(minutes: durationMinutes));
      final roomRef = _db.collection('studyRooms').doc(roomId);
      batch.update(roomRef, {
        'isAvailable': false,
        'currentSessionId': doc.id,
        'currentGroupName': title,
        'occupiedUntil': Timestamp.fromDate(until),
      });
    }

    await batch.commit();
    return session;
  }

  
  Future<void> endSession(String sessionId) async {
    final docRef = _db.collection('sessions').doc(sessionId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final String? roomId = data['roomId'] as String?;

    final batch = _db.batch();
    batch.update(docRef, {'status': 'completed'});

    if (roomId != null && roomId.isNotEmpty) {
      final roomRef = _db.collection('studyRooms').doc(roomId);
      batch.update(roomRef, {
        'isAvailable': true,
        'currentSessionId': null,
        'currentGroupName': null,
        'occupiedUntil': null,
      });
    }

    await batch.commit();
  }



  Stream<List<StudySession>> streamUpcomingSessions(String groupId) {
    final now = DateTime.now();
    return _db
        .collection('sessions')
        .where('groupId', isEqualTo: groupId)
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StudySession.fromDoc(d.id, d.data())).toList());
  }
}
