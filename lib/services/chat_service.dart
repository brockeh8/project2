import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_message.dart';
import 'auth_service.dart';

class ChatService {
    final _db = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final _authService = AuthService();

   Stream<List<GroupMessage>> streamMessages(String groupId) {
        return _db
            .collection('groupMessages')
            .where('groupId', isEqualTo: groupId)
            .snapshots()
            .map((snap) {
            final list = snap.docs
                .map((d) => GroupMessage.fromDoc(d.id, d.data()))
                .toList();

            list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            return list;
        });
    }

    Future<void> sendMessage(String groupId, String text) async {
        final trimmed = text.trim();
        if (trimmed.isEmpty) return;

        final uid = _auth.currentUser!.uid;
        final name = await _authService.getDisplayName(uid);

        final doc = _db.collection('groupMessages').doc();
        final msg = GroupMessage(
            id: doc.id,
            groupId: groupId,
            senderUid: uid,
            senderName: name,
            text: text.trim(),
            timestamp: DateTime.now(),
        );

        await doc.set(msg.toMap());
    }
}
