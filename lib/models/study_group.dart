class StudyGroup {
    final String id;
    final String name;
    final String courseCode;
    final String description;
    final String ownerUid;
    final List<String> memberUids;

    StudyGroup({
        required this.id,
        required this.name,
        required this.courseCode,
        required this.description,
        required this.ownerUid,
        required this.memberUids,
    });

    Map<String, dynamic> toMap() => {
            'name': name,
            'courseCode': courseCode,
            'description': description,
            'ownerUid': ownerUid,
            'memberUids': memberUids,
            'createdAt': DateTime.now().toUtc(),
        };

    static StudyGroup fromDoc(String id, Map<String, dynamic> map) {
        return StudyGroup(
            id: id,
            name: map['name'] ?? '',
            courseCode: map['courseCode'] ?? '',
            description: map['description'] ?? '',
            ownerUid: map['ownerUid'] ?? '',
            memberUids: (map['memberUids'] as List?)?.cast<String>() ?? [],
        );
    }
}
