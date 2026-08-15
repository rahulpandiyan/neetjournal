import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'desktop_google_auth.dart';
import 'google_credentials.dart';

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

  bool _googleInitialized = false;

  /// Resolves the desktop OAuth client secret from `--dart-define` or the
  /// local (git-ignored) `~/.studyn/google_secret` file. Returns null when it
  /// is not configured, so sign-in can fail with a helpful message.
  String? _googleClientSecret() {
    if (googleDesktopClientSecret.isNotEmpty) {
      return googleDesktopClientSecret;
    }
    try {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final file = File('$home/.studyn/google_secret');
        if (file.existsSync()) {
          final value = file.readAsStringSync().trim();
          if (value.isNotEmpty) return value;
        }
      }
    } catch (_) {
      // Fall through to the missing-configuration error below.
    }
    return null;
  }

  Future<UserCredential> signInWithGoogle() async {
    // Desktop (Linux/Windows) has no google_sign_in platform implementation, so
    // use the browser-based OAuth authorization-code flow instead.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows)) {
      final secret = _googleClientSecret();
      if (secret == null) {
        throw FirebaseAuthException(
          code: 'google-client-secret-missing',
          message: 'Desktop Google sign-in is not configured. Provide the '
              'OAuth client secret via --dart-define=GOOGLE_CLIENT_SECRET=... '
              'or the ~/.studyn/google_secret file.',
        );
      }
      final auth = DesktopGoogleAuth(
        clientId: googleDesktopClientId,
        clientSecret: secret,
      );
      final tokens = await auth.signIn();
      final credential = GoogleAuthProvider.credential(
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );
      return _auth.signInWithCredential(credential);
    }

    // Android/iOS/macOS/web go through google_sign_in. `initialize()` must
    // complete before anything else; on Android it reads the web client ID
    // from google-services.json so an ID token is actually requested.
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize();
      _googleInitialized = true;
    }

    try {
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'google-id-token-missing',
          message: 'Google did not return an ID token. Check the Firebase '
              'OAuth client (SHA-1) configuration.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      // v7 reports cancellation and UI issues as GoogleSignInException.
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Google sign-in was cancelled.',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.description ?? 'Google sign-in failed.',
      );
    }
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
