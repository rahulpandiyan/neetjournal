import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:window_to_front/window_to_front.dart';

/// Google Sign-In for desktop (Linux/Windows) using the standard OAuth 2.0
/// authorization-code flow through the system browser.
///
/// `google_sign_in` has no desktop platform implementation, so the app opens
/// Google's consent page in the default browser, Google redirects back to a
/// local loopback address served by this app, and the resulting authorization
/// code is exchanged for an ID token that Firebase accepts.
/// See https://developers.google.com/identity/protocols/oauth2/native-app
class DesktopGoogleAuth {
  const DesktopGoogleAuth({
    required this.clientId,
    required this.clientSecret,
  });

  /// The "Web application" OAuth client Firebase auto-created for this
  /// project (client_type 3 in google-services.json).
  final String clientId;

  /// Client secret for the same OAuth client. For a client-side desktop app
  /// this is not a secret (it ships in the binary) and is what the loopback
  /// flow uses to exchange the authorization code.
  final String clientSecret;

  /// Fixed loopback port so the redirect URI can be registered in the Google
  /// Cloud Console. Google ignores the port when matching loopback redirect
  /// URIs, but a fixed value keeps the registration deterministic.
  static const int redirectPort = 8431;

  static const Duration _authTimeout = Duration(minutes: 5);

  static final Uri _authorizationEndpoint =
      Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');
  static final Uri _tokenEndpoint =
      Uri.parse('https://oauth2.googleapis.com/token');

  Uri get _redirectUri => Uri.parse('http://localhost:$redirectPort');

  static const String _landingPage = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Sign-in complete</title>
  <style>
    html, body { margin: 0; height: 100%; }
    main { height: 100%; display: flex; align-items: center; justify-content: center;
           font-family: sans-serif; background: #f4f5f3; color: #1f2937; }
  </style>
</head>
<body><main>Sign-in successful. You can close this tab and return to Studyn.</main></body>
</html>
''';

  /// Opens the browser, waits for the consent result, exchanges the code and
  /// returns the Google tokens for the signed-in account.
  Future<GoogleTokenResult> signIn() async {
    final state = _randomState();
    final authUrl = _authorizationEndpoint.replace(queryParameters: {
      'client_id': clientId,
      'redirect_uri': _redirectUri.toString(),
      'response_type': 'code',
      'scope': 'openid email profile',
      'state': state,
      'prompt': 'select_account',
    });

    String? code;
    try {
      code = await _runLoopbackFlow(authUrl, state);
    } on TimeoutException {
      throw FirebaseAuthException(
        code: 'aborted-by-user',
        message: 'Google sign-in timed out. Please try again.',
      );
    } on SocketException {
      throw FirebaseAuthException(
        code: 'desktop-auth-failed',
        message: 'Could not start the local sign-in server '
            '(port $redirectPort is in use). Close any app using it and retry.',
      );
    }

    if (code == null) {
      throw FirebaseAuthException(
        code: 'oauth-no-code',
        message: 'Google did not return an authorization code.',
      );
    }

    final response = await http.post(
      _tokenEndpoint,
      headers: const {'Accept': 'application/json'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri.toString(),
      },
    );

    if (response.statusCode != 200) {
      String message = 'Token exchange failed (${response.statusCode}).';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = body['error_description'] ?? body['error'];
        if (detail != null) message = 'Google rejected the sign-in: $detail';
      } catch (_) {
        // Keep the generic message if the body is not JSON.
      }
      throw FirebaseAuthException(
        code: 'oauth-token-exchange-failed',
        message: message,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final idToken = body['id_token'] as String?;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'oauth-no-id-token',
        message: 'Google returned no ID token.',
      );
    }
    return GoogleTokenResult(
      idToken: idToken,
      accessToken: body['access_token'] as String?,
    );
  }

  /// Serves a one-shot loopback HTTP server that captures Google's redirect.
  ///
  /// The browser is opened first and the server waits for exactly one request
  /// (Google redirects to `http://localhost:8431/?code=...&state=...`).
  /// Returns the authorization code, or null if the callback carried none.
  Future<String?> _runLoopbackFlow(Uri authUrl, String state) async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      redirectPort,
    );
    try {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);

      final request = await server.first.timeout(_authTimeout);
      final callback = request.requestedUri;
      request.response.headers.contentType = ContentType.html;
      request.response.write(_landingPage);
      await request.response.close();

      if (callback.queryParameters['state'] != state) {
        throw FirebaseAuthException(
          code: 'oauth-state-mismatch',
          message: 'OAuth state mismatch. Please try again.',
        );
      }
      return callback.queryParameters['code'];
    } finally {
      await server.close(force: true);
      // Bring the app window back to the foreground after the browser dance.
      try {
        await WindowToFront.activate();
      } catch (_) {
        // Ignore: focus restoration is best-effort.
      }
    }
  }

  String _randomState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}

/// Result of the desktop Google sign-in.
class GoogleTokenResult {
  GoogleTokenResult({required this.idToken, this.accessToken});

  final String idToken;
  final String? accessToken;
}
