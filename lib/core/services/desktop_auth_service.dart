import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import 'app_user.dart';
import 'auth_service.dart';

/// Email/password sign-in for Linux/Windows desktop.
///
/// Firebase's official FlutterFire packages ship no Linux/Windows
/// implementation, so [FirebaseAuth.instance] cannot work there. Instead this
/// talks to the same Firebase Authentication REST API with a pure-Dart client,
/// persisting the refresh token locally so the session survives restarts.
///
/// The returned auth surface matches the native path so the UI and Riverpod
/// providers stay identical; errors are normalized to [FirebaseAuthException]
/// codes the login/signup screens already understand.
class DesktopAuthService extends AuthService {
  DesktopAuthService() {
    _restore();
  }

  static const _tokenKey = 'studyn_desktop_refresh_token';

  final http.Client _client = http.Client();
  late final FirebaseAuth _auth = FirebaseAuth(
    _client,
    DefaultFirebaseOptions.linux.apiKey,
  );
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  FirebaseAccount? _account;
  AppUser? _user;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => _user;

  /// Restores a previously signed-in session (if any) from the stored refresh
  /// token. Always emits once so [authStateProvider] resolves.
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print(
        '[studyn-auth] restore: refresh token '
        '${(token == null || token.isEmpty) ? 'ABSENT' : 'present'}',
      );
      if (token == null || token.isEmpty) {
        _emitIfAbsent();
        return;
      }
      final account = await _auth.restoreAccount(token);
      print('[studyn-auth] restore: OK uid=${account.localId}');
      _adopt(account, persist: false);
      unawaited(_loadEmail());
    } catch (e, s) {
      print('[studyn-auth] restore: FAILED $e');
      print(s);
      await _clearPersisted();
      _emitIfAbsent();
    }
  }

  /// A restored session never carries the email (the token exchange response
  /// has no profile), so fetch it best-effort so Settings can show who is
  /// signed in.
  Future<void> _loadEmail() async {
    try {
      final details = await _account?.getDetails();
      final email = details?.email;
      print('[studyn-auth] restore: email=${email ?? '<none>'}');
      if (_user == null || email == null || email.isEmpty) return;
      _user = AppUser(uid: _user!.uid, email: email);
      _emit(_user);
    } catch (e, s) {
      print('[studyn-auth] restore: email fetch FAILED $e');
      print(s);
    }
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    print('[studyn-auth] signIn: $email');
    try {
      final account = await _guard(
        () => _auth.signInWithPassword(email, password),
      );
      final user = _adopt(account, email: email);
      print('[studyn-auth] signIn: OK uid=${user.uid}');
      return user;
    } catch (e) {
      print('[studyn-auth] signIn: FAILED $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password) async {
    print('[studyn-auth] signUp: $email');
    try {
      final account = await _guard(
        () => _auth.signUpWithPassword(email, password, autoVerify: false),
      );
      final user = _adopt(account, email: email);
      print('[studyn-auth] signUp: OK uid=${user.uid}');
      return user;
    } catch (e) {
      print('[studyn-auth] signUp: FAILED $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    print('[studyn-auth] signOut');
    await _account?.dispose();
    _account = null;
    _user = null;
    await _clearPersisted();
    _emit(null);
  }

  @override
  Future<String?> getIdToken() async {
    final account = _account;
    if (account == null) return null;
    try {
      final token = await account.refresh();
      print('[studyn-auth] getIdToken: OK');
      return token;
    } catch (e) {
      print('[studyn-auth] getIdToken: FAILED $e');
      return null;
    }
  }

  AppUser _adopt(
    FirebaseAccount account, {
    String? email,
    bool persist = true,
  }) {
    _account?.dispose();
    _account = account;
    _user = AppUser(uid: account.localId, email: email);
    if (persist) {
      unawaited(_persist(account.refreshToken));
    }
    _emit(_user);
    return _user!;
  }

  Future<void> _persist(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, refreshToken);
    } catch (e) {
      print('[studyn-auth] persist refresh token FAILED $e');
      // Persistence is best-effort: the session just won't survive a restart.
    }
  }

  Future<void> _clearPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {
      // Ignore; clearing a missing token is harmless.
    }
  }

  void _emit(AppUser? user) {
    if (!_controller.isClosed) {
      _controller.add(user);
    }
  }

  void _emitIfAbsent() {
    if (_user == null) _emit(null);
  }

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on AuthException catch (e) {
      throw _mapError(e);
    } on SocketException {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error. Check your connection and try again.',
      );
    } on http.ClientException {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error. Check your connection and try again.',
      );
    }
  }

  /// Maps Firebase REST error codes to [FirebaseAuthException] codes so the
  /// shared login/signup error text applies on desktop too.
  FirebaseAuthException _mapError(AuthException e) {
    final raw = e.error.message ?? '';
    switch (raw.split(':').first.trim()) {
      case 'EMAIL_EXISTS':
        return FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account with this email already exists. Try signing in.',
        );
      case 'EMAIL_NOT_FOUND':
        return FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found for this email.',
        );
      case 'INVALID_PASSWORD':
        return FirebaseAuthException(
          code: 'wrong-password',
          message: 'Incorrect password. Please try again.',
        );
      case 'INVALID_EMAIL':
        return FirebaseAuthException(
          code: 'invalid-email',
          message: 'Enter a valid email address.',
        );
      case 'INVALID_LOGIN_CREDENTIALS':
        return FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Incorrect email or password. Please try again.',
        );
      case 'USER_DISABLED':
        return FirebaseAuthException(
          code: 'user-disabled',
          message: 'This account has been disabled.',
        );
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return FirebaseAuthException(
          code: 'too-many-requests',
          message: 'Too many attempts. Please try again later.',
        );
      case 'WEAK_PASSWORD':
        return FirebaseAuthException(
          code: 'weak-password',
          message: 'Password is too weak. Use at least 6 characters.',
        );
      default:
        return FirebaseAuthException(
          code: 'unknown',
          message: raw.isEmpty ? 'Sign-in failed. Please try again.' : raw,
        );
    }
  }

  @override
  Future<void> dispose() async {
    await _account?.dispose();
    await _controller.close();
    _client.close();
  }
}
