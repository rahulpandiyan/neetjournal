import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_shell.dart';

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
    final service = ref.read(notificationsServiceProvider);
    await service.init();
    await service.requestPermissions();
    await syncNotifications(ref);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studyn',
      debugShowCheckedModeBanner: false,
      color: AppTheme.light().colorScheme.surface,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeShell(),
    );
  }
}
