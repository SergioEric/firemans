import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Future<AuthResult>login() async {
    AuthResult authUser = await _firebaseAuth.signInAnonymously();

    return authUser ?? null;
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }
}
