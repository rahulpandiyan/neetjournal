import 'package:firebase_auth/firebase_auth.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController(text: '+91');
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

  String _getFullPhone() {
    var value = _phone.text.trim();
    if (!value.startsWith('+91')) {
      value = '+91' + value.replaceAll(RegExp(r'\D'), '');
    }
    return value;
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).sendPhoneOTP(
            phoneNumber: _getFullPhone(),
            autoVerify: (credential) async {
              setState(() => _autoVerified = true);
              await ref.read(authServiceProvider).signInWithCredential(credential);
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

  String _extractFirebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid phone number (e.g. 9876543210)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Sign up failed.';
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
      title: 'Create account',
      subtitle: 'Sign up with your mobile number.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                autocorrect: false,
                textInputAction: _otpSent ? TextInputAction.done : TextInputAction.next,
                onFieldSubmitted: _otpSent ? (_) => _verifyOTP() : null,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '98765 43210',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  prefixText: '+91 ',
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Enter your phone number';
                  final digits = value.replaceFirst('+91', '').replaceAll(RegExp(r'\D'), '');
                  if (digits.length != 10) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              if (_otpSent) ...[
                TextFormField(
                  controller: _otp,
                  keyboardType: const TextInputType.numberWithOptions(signed: false),
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
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 20),
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
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
