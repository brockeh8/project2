class StudyRoom {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final bool isAvailable;

  StudyRoom({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'building': building,
        'floor': floor,
        'capacity': capacity,
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now().toUtc(),
      };

  static StudyRoom fromDoc(String id, Map<String, dynamic> map) {
    return StudyRoom(
      id: id,
      name: map['name'] ?? '',
      building: map['building'] ?? '',
      floor: map['floor'] ?? 0,
      capacity: map['capacity'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
