import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
    final String id;
    final String groupId;
    final String senderUid;
    final String senderName;
    final String text;
    final DateTime timestamp;

    GroupMessage({
        required this.id,
        required this.groupId,
        required this.senderUid,
        required this.senderName,
        required this.text,
        required this.timestamp,
    });

    Map<String, dynamic> toMap() => {
        return{
            'groupId': groupId,
            'senderUid': senderUid,
            'senderName': senderName,
            'text': text,
            'timestamp': timestamp.fromDate(timestamp),
        };
    }

    static GroupMessage fromDoc(String id, Map<String, dynamic> map) {
        final ts = map['timestamp'];
        DateTime time;
        if (ts is Timestamp) {
            time = ts.toDate();
        } 
        else if (ts is DateTime) {
            time = ts;
        } 
        else {
            time = DateTime.now();
        }


        return GroupMessage(
        id: id,
        groupId: map['groupId'] ?? '',
        senderUid: map['senderUid'] ?? '',
        senderName: map['senderName'] ?? 'User',
        text: map['text'] ?? '',
        timestamp: time,
        );
    }
}
