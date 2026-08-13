import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_shell.dart';

class NeetJournalApp extends ConsumerWidget {
  const NeetJournalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Touch the DB provider once at startup so seeding/migration runs early.
    ref.watch(databaseProvider);

    return MaterialApp(
      title: 'NEET Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeShell(),
    );
  }
}
