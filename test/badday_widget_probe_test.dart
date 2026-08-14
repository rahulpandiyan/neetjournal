import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/state/providers.dart';
import 'package:studyn/ui/screens/today/today_screen.dart';

void main() {
  testWidgets('bad day toggle reveals the minimum card', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodayScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("I'm having a bad day"), findsOneWidget);
    expect(find.text("TODAY'S MINIMUM"), findsNothing);

    await tester.tap(find.byType(Switch));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.text("TODAY'S MINIMUM"), findsOneWidget);

    container.dispose();
    await db.close();
  });
}
