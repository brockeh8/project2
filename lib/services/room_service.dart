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
}
