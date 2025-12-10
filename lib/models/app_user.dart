class AppUser {
    final String uid;
    final String campusId;
    final String fullName;
    final String email;

    AppUser({
        required this.uid,
        required this.campusId,
        required this.fullName,
        required this.email,
    });

    Map<String, dynamic> toMap() => {
        'uid': uid,
        'campusId': campusId,
        'fullName': fullName,
        'email': email,
        'createdAt': DateTime.now().toUtc(),
    };
}
