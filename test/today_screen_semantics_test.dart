import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/state/providers.dart';
import 'package:studyn/ui/screens/today/today_screen.dart';

void main() {
  testWidgets('TodayScreen with semantics enabled does not assert', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodayScreen()),
      ),
    );

    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (i == 5 || i == 8 || i == 12) {
        await tester.drag(find.byType(ListView), const Offset(0, -150));
        await tester.pump();
      }
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);

    container.dispose();
    await db.close();
    handle.dispose();
  });
}
