import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/auth_providers.dart';
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
class _ForegroundReminderListener extends ConsumerStatefulWidget {
  const _ForegroundReminderListener({required this.child});

  final Widget child;

  @override
  ConsumerState<_ForegroundReminderListener> createState() =>
      _ForegroundReminderListenerState();
}

class _ForegroundReminderListenerState
    extends ConsumerState<_ForegroundReminderListener> {
  /// The uid cloud sync was started for. `ref.listen` may only be called from
  /// [build], so this guard keeps a given user's sync started exactly once.
  String? _syncUid;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      if (uid != _syncUid) {
        _syncUid = uid;
        // A user signed in (or was restored): start cloud sync. Watching (not
        // reading/listening) is what keeps the StreamProvider alive so it runs
        // in the background. The provider keeps its own error handling
        // (Firestore missing on desktop) and the Settings tile shows status.
        print('[studyn-sync] auth: signed in uid=$uid, starting sync');
      }
      ref.watch(activeSyncProvider(uid));
    } else if (uid == null && _syncUid != null) {
      final oldUid = _syncUid!;
      print('[studyn-sync] auth: signed out uid=$oldUid, stopping sync');
      ref.invalidate(syncServiceProvider);
      ref.invalidate(activeSyncProvider(oldUid));
      _syncUid = null;
    }
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
    return widget.child;
  }
}
