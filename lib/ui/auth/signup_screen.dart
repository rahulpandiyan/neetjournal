import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_providers.dart';
import 'auth_scaffold.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _loading = false;

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'aborted-by-user') {
        String msg = e.message ?? 'Google sign-in failed.';
        if (msg.contains('oauth') || msg.contains('OAuth') ||
            msg.contains('client') ||
            (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows))) {
          msg = 'Google Sign-In requires OAuth setup for desktop. '
              'Go to Firebase Console → Project Settings → Your apps → '
              'Add Desktop OAuth client, then rebuild.';
        }
        _showError(msg);
      }
    } catch (_) {
      _showError(
        'Google sign-in failed. On desktop it needs an OAuth client configured '
        'in Firebase Console.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthScaffold(
      title: 'Create Account',
      subtitle: 'Sign up with Google to get started.',
      children: [
        FilledButton.icon(
          onPressed: _loading ? null : _google,
          icon: const GoogleG(size: 22),
          label: const Text('Sign up with Google'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}
