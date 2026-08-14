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

  /// Sends an OTP to [phoneNumber] (e.g. "+919876543210").
  /// On Android/iOS the OS may auto-verify and call [autoVerify].
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    void Function(PhoneAuthCredential)? autoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-verified on Android/iOS — sign in immediately.
        autoVerify?.call(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        // Update the verification ID so the UI can use it.
        _currentVerificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _currentVerificationId = verificationId;
      },
    );
  }

  String? _currentVerificationId;

  String? get currentVerificationId => _currentVerificationId;

  /// Verifies [smsCode] against the most recently received verification ID.
  Future<UserCredential> verifyPhoneOTP(String smsCode) async {
    if (_currentVerificationId == null) {
      throw FirebaseAuthException(
        code: 'no-verification-id',
        message: 'No verification ID available. Please request a new OTP.',
      );
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _currentVerificationId!,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
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
