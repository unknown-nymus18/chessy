import 'package:chessy/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  Database db = Database();

  Future<void> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      if (auth.currentUser != null) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        db.createUser(
          username: username,
          uid: auth.currentUser!.uid,
          timestamp: Timestamp.now(),
          email: email,
        );
      }
    } catch (e) {
      print('error');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }
}
