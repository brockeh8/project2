class StudySession {
  final String id;
  final String groupId;
  final String createdByUid;
  final DateTime startTime;
  final int durationMinutes;
  final bool isActive;

  StudySession({
    required this.id,
    required this.groupId,
    required this.createdByUid,
    required this.startTime,
    required this.durationMinutes,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'createdByUid': createdByUid,
        'startTime': startTime.toUtc(),
        'durationMinutes': durationMinutes,
        'isActive': isActive,
        'createdAt': DateTime.now().toUtc(),
      };

  static StudySession fromDoc(String id, Map<String, dynamic> map) {
    final st = map['startTime'];
    final dt = st?.toDate() as DateTime? ?? DateTime.now();

    return StudySession(
      id: id,
      groupId: map['groupId'] ?? '',
      createdByUid: map['createdByUid'] ?? '',
      startTime: dt,
      durationMinutes: map['durationMinutes'] ?? 25,
      isActive: map['isActive'] ?? true,
    );
  }
}
