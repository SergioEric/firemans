import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Future<AuthResult>login() async {
    AuthResult authUser = await _firebaseAuth.signInWithEmailAndPassword(email: "bb@gmail.com", password: "123456");

    return authUser ?? null;
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  void getLogOut() async {
    return await _firebaseAuth.signOut();
  }
}
