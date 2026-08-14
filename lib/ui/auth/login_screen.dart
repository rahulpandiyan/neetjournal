import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_providers.dart';
import 'auth_scaffold.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _otp = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;
  bool _autoVerified = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).sendPhoneOTP(
            phoneNumber: _phone.text.trim(),
            autoVerify: (credential) async {
              setState(() => _autoVerified = true);
              await _handleSignedIn();
            },
          );
      if (mounted) setState(() => _otpSent = true);
    } on FirebaseAuthException catch (e) {
      _showError(_extractFirebaseMessage(e));
    } catch (e) {
      _showError('Failed to send OTP. Please check your phone number.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otp.text.trim().isEmpty) {
      _showError('Enter the OTP sent to your phone');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).verifyPhoneOTP(_otp.text.trim());
      await _handleSignedIn();
    } on FirebaseAuthException catch (e) {
      _showError(_extractFirebaseMessage(e));
    } catch (e) {
      _showError('Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      await _handleSignedIn();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'aborted-by-user') {
        _showError(e.message ?? 'Google sign-in failed.');
      }
    } catch (_) {
      _showError(
        'Google sign-in failed. On desktop it needs an OAuth client in the '
        'Firebase console.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSignedIn() async {
    // Sign-in successful — navigate is handled by the auth state listener.
  }

  String _extractFirebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid phone number with country code (e.g. +919876543210)';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Sign in failed.';
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
      title: 'Sign in',
      subtitle: 'Enter your mobile number to continue.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone number input.
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                autocorrect: false,
                textInputAction: _otpSent ? TextInputAction.done : TextInputAction.next,
                onFieldSubmitted: _otpSent ? (_) => _verifyOTP() : null,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '+91 98765 43210',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Enter your phone number';
                  // Basic check: must start with + and have 10-15 digits
                  if (!value.startsWith('+') || value.length < 10) {
                    return 'Enter a valid phone number with country code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // OTP input (shown after OTP is sent).
              if (_otpSent) ...[
                TextFormField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  maxLength: 6,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _verifyOTP(),
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: '6-digit code',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Send OTP or Verify button.
              FilledButton(
                onPressed: _loading
                    ? null
                    : _otpSent
                        ? _verifyOTP
                        : _sendOTP,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
              ),

              if (_autoVerified) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Auto-verified ✓',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loading ? null : _google,
                icon: const GoogleG(size: 20),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          ),
                  child: const Text('Use email instead'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
