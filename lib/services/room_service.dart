import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_room.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  Stream<List<StudyRoom>> streamRooms({
    String? search,
    bool availableOnly = false,
  }) {
    return _db.collection('studyRooms').snapshots().map((snap) {
      var list = snap.docs
          .map((d) => StudyRoom.fromDoc(d.id, d.data()))
          .toList();

      if (availableOnly) {
        list = list.where((r) => r.isAvailable).toList();
      }

      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where(
          (r) =>
              r.name.toLowerCase().contains(q) ||
              r.building.toLowerCase().contains(q),
        ).toList();
      }

      list.sort((a, b) => a.building.compareTo(b.building));
      return list;
    });
  }

  Future<void> toggleAvailability(String roomId, bool newValue) async {
    await _db.collection('studyRooms').doc(roomId).update({
      'isAvailable': newValue,
      'updatedAt': DateTime.now().toUtc(),
    });
  }

//seeding rooms
  Future<void> seedDefaultRooms() async {
    final rooms = <StudyRoom>[
      StudyRoom(
        id: 'room1',
        name: 'Study Room 201',
        building: 'Library North',
        floor: 2,
        capacity: 6,
        isAvailable: true,
      ),
      StudyRoom(
        id: 'room2',
        name: 'Study Room 202',
        building: 'Library North',
        floor: 2,
        capacity: 4,
        isAvailable: false,
      ),
      StudyRoom(
        id: 'room3',
        name: 'Quiet Study 310',
        building: 'Student Center East',
        floor: 3,
        capacity: 8,
        isAvailable: true,
      ),
      StudyRoom(
        id: 'room4',
        name: 'Group Study 115',
        building: 'Classroom South',
        floor: 1,
        capacity: 5,
        isAvailable: true,
      ),
      StudyRoom(
        id: 'room5',
        name: 'Study Pod A',
        building: 'Aderhold Hall',
        floor: 2,
        capacity: 3,
        isAvailable: false,
      ),
      StudyRoom(
        id: 'room6',
        name: 'Study Pod B',
        building: 'Aderhold Hall',
        floor: 2,
        capacity: 3,
        isAvailable: true,
      ),
      StudyRoom(
        id: 'room7',
        name: 'Collab Space 105',
        building: 'Library South',
        floor: 1,
        capacity: 10,
        isAvailable: false,
      ),
      StudyRoom(
        id: 'room8',
        name: 'Study Lounge',
        building: 'Urban Life',
        floor: 4,
        capacity: 12,
        isAvailable: true,
      ),
    ];

    final batch = _db.batch();
    for (final room in rooms) {
      final docRef = _db.collection('studyRooms').doc(room.id);
      batch.set(docRef, room.toMap());
    }
    await batch.commit();
  }
}
