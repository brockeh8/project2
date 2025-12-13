import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String groupId;
  final String? roomId;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final String status; 
  final String createdByUid;

  StudySession({
    required this.id,
    required this.groupId,
    required this.roomId,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    required this.createdByUid,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'roomId': roomId,
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'status': status,
      'createdByUid': createdByUid,
    };
  }

  static StudySession fromDoc(String id, Map<String, dynamic> map) {
    final ts = map['startTime'];
    final start = ts is Timestamp ? ts.toDate() : DateTime.now();

    return StudySession(
      id: id,
      groupId: map['groupId'] ?? '',
      roomId: map['roomId'],
      title: map['title'] ?? '',
      startTime: start,
      durationMinutes: (map['durationMinutes'] ?? 25) as int,
      status: map['status'] ?? 'scheduled',
      createdByUid: map['createdByUid'] ?? '',
    );
  }
}
