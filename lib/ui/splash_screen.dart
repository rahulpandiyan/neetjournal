import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_providers.dart';
import '../ui/auth/login_screen.dart';
import '../ui/auth/signup_screen.dart';
import '../ui/onboarding/oath_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for Firebase to initialize (if configured).
    final container = ProviderScope.containerOf(context, listen: false);
    final firebase = container.read(firebaseAppProvider);
    if (firebase == null) {
      // Firebase not configured: show placeholder auth gate.
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    // Listen for auth changes; once resolved, decide next.
    final asyncValue = container.read(authStateProvider);
    asyncValue.whenData((user) {
      if (!mounted) return;
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OathScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 160,
          height: 160,
        ),
      ),
    );
  }
}
