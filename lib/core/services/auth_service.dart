import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around [FirebaseAuth] so the UI talks to a stable surface and
/// platform quirks (Google sign-in on desktop) stay contained.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final google = GoogleSignIn.instance;

    // Desktop (Windows/Linux) needs an interactive sign-in that opens the
    // browser; the `google_sign_in_*` desktop federations do this for us.
    final account = await google.authenticate();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'aborted-by-user',
        message: 'Google sign-in was cancelled.',
      );
    }
    final authentication = account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }
}
