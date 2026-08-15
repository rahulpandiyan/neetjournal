import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_providers.dart';
import '../ui/auth/login_screen.dart';
import '../ui/onboarding/oath_screen.dart';
import '../ui/screens/home_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for Firebase to initialize (resolves null on platforms FlutterFire
    // doesn't support, like Linux/Windows, where auth falls back to REST).
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(firebaseAppProvider.future);
    if (!mounted) return;

    // Check the sign-in state regardless of whether Firebase initialized.
    final authState = await container.read(authStateProvider.future);
    if (!mounted) return;

    if (authState == null) {
      // Not logged in.
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    // Logged in: check oath status.
    final oathTaken = await container.read(oathTakenProvider.future);
    if (!mounted) return;

    if (oathTaken == false) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const OathScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    }
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
