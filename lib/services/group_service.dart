import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_group.dart';

class GroupService {
    final _db = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;

    Stream<List<StudyGroup>> streamGroups() {
        return _db.collection('groups')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snap) =>
                snap.docs.map((d) => StudyGroup.fromDoc(d.id, d.data())).toList());
    }

    Future<void> createGroup({
        required String name,
        required String courseCode,
        required String description,
    }) async {
        final uid = _auth.currentUser!.uid;
        final doc = _db.collection('groups').doc();

        final g = StudyGroup(
            id: doc.id,
            name: name.trim(),
            courseCode: courseCode.trim(),
            description: description.trim(),
            ownerUid: uid,
            memberUids: [uid],
        );

        await doc.set(g.toMap());
    }

    Future<void> joinGroup(String groupId) async {
        final uid = _auth.currentUser!.uid;
        await _db.collection('groups').doc(groupId).update({
            'memberUids': FieldValue.arrayUnion([uid]),
        });
    }

    Future<void> leaveGroup(String groupId) async {
        final uid = _auth.currentUser!.uid;
        await _db.collection('groups').doc(groupId).update({
            'memberUids': FieldValue.arrayRemove([uid]),
        });
    }

    Stream<StudyGroup> streamGroup(String groupId) {
        return _db.collection('groups').doc(groupId).snapshots().map((doc) {
            return StudyGroup.fromDoc(doc.id, doc.data() ?? {});
        });
    }
}
