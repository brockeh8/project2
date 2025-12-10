import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
    final _auth = FirebaseAuth.instance;
    final _db = FirebaseFirestore.instance;

    String campusToEmail(String input) {
        final t = input.trim();
        if (t.contains('@')) return t;
        return '$t@gsu.edu';
    }

    Future<void> login({
        required String campusIdOrEmail,
        required String password,
    }) async {
        final email = campusToEmail(campusIdOrEmail);
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    }

    Future<void> register({
        required String campusId,
        required String fullName,
        required String email,
        required String password,
    }) async {
        final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
        );

        final user = AppUser(
        uid: cred.user!.uid,
        campusId: campusId.trim(),
        fullName: fullName.trim(),
        email: email.trim(),
        );

        await _db.collection('users').doc(user.uid).set(user.toMap());
    }

    Future<String> getDisplayName(String uid) async {
        final doc = await _db.collection('users').doc(uid).get();
        return doc.data()?['fullName'] ?? 'User';
    }

    Future<void> signOut() async => _auth.signOut();
}
