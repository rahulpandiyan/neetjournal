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
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          autoVerify?.call(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          _currentVerificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      // Provide better error messages
      String message = e.message ?? 'Sign in failed.';
      switch (e.code) {
        case 'invalid-phone-number':
          message = 'Invalid phone number. Make sure it includes country code (e.g. +919876543210)';
          break;
        case 'missing-android-package-name':
          message = 'Missing Android package name. Check google-services.json configuration.';
          break;
        case 'missing-signature':
          message = 'Missing app signature. Add your SHA-1 key to Firebase Console.';
          break;
        case 'invalid-project':
          message = 'Invalid Firebase project. Check your project configuration.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please wait and try again later.';
          break;
        case 'app-not-authorized':
          message = 'App not authorized to use Firebase Authentication. Check your Firebase configuration.';
          break;
        default:
          break;
      }
      throw FirebaseAuthException(code: e.code, message: message);
    }
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
      // User cancelled or aborted
      return _auth.currentUser != null
          ? UserCredential(user: _auth.currentUser, additionalUserInfo: null)
          : throw FirebaseAuthException(
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
