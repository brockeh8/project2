import 'package:cloud_firestore/cloud_firestore.dart';

class StudyRoom {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final bool isAvailable;
  final String? currentSessionId;
  final String? currentGroupName;
  final DateTime? occupiedUntil;

  StudyRoom({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.isAvailable,
    this.currentSessionId,
    this.currentGroupName,
    this.occupiedUntil,
  });

  bool get isOccupied => !isAvailable || currentSessionId != null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'isAvailable': isAvailable,
      'currentSessionId': currentSessionId,
      'currentGroupName': currentGroupName,
      'occupiedUntil':
          occupiedUntil != null ? Timestamp.fromDate(occupiedUntil!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static StudyRoom fromDoc(String id, Map<String, dynamic> map) {
    final ts = map['occupiedUntil'];
    DateTime? until;
    if (ts is Timestamp) until = ts.toDate();

    return StudyRoom(
      id: id,
      name: map['name'] ?? '',
      building: map['building'] ?? '',
      floor: (map['floor'] ?? 0) as int,
      capacity: (map['capacity'] ?? 0) as int,
      isAvailable: (map['isAvailable'] ?? true) as bool,
      currentSessionId: map['currentSessionId'],
      currentGroupName: map['currentGroupName'],
      occupiedUntil: until,
    );
  }
}
