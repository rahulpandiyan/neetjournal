import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'state/reminder_controller.dart';
import 'theme/app_theme.dart';
import 'ui/splash_screen.dart';

class NeetJournalApp extends ConsumerStatefulWidget {
  const NeetJournalApp({super.key});

  @override
  ConsumerState<NeetJournalApp> createState() => _NeetJournalAppState();
}

class _NeetJournalAppState extends ConsumerState<NeetJournalApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Touch the DB provider once so seeding/migration runs early.
      ref.read(databaseProvider);
      _setupNotifications();
    });
  }

  Future<void> _setupNotifications() async {
    try {
      final service = ref.read(notificationsServiceProvider);
      await service.init();
      await service.requestPermissions();
      await syncNotifications(ref);
    } catch (_) {
      // Notifications are best-effort: never let a platform/init failure
      // take down the app (e.g. a timezone lookup quirk on Windows/Linux).
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studyn',
      debugShowCheckedModeBanner: false,
      color: AppTheme.light().colorScheme.surface,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: _ForegroundReminderListener(child: const SplashScreen()),
    );
  }
}

/// Shows an in-app dialog when the foreground reminder watcher fires (rest
/// reminders at study-slot end) so the prompt appears inside the app while the
/// OS notification still covers the background case.
class _ForegroundReminderListener extends ConsumerWidget {
  const _ForegroundReminderListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ForegroundReminder?>(foregroundReminderProvider, (_, next) {
      if (next == null) return;
      final reminder = next;
      unawaited(
        ref
            .read(notificationsServiceProvider)
            .showImmediately(title: reminder.title, body: reminder.body)
            .catchError((_) {}),
      );
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Time to rest'),
          content: Text(reminder.body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(foregroundReminderProvider.notifier).dismissed();
              },
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    });
    return child;
  }
}
