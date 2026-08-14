import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:studyn/core/db/database.dart';
import 'package:studyn/state/providers.dart';
import 'package:studyn/ui/screens/timetable/timetable_screen.dart';

class _FakeNotificationsPlatform extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {}

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  testWidgets(
    'Editing a timetable slot does not throw render/semantics errors',
    (tester) async {
      final handle = tester.ensureSemantics();
      FlutterLocalNotificationsPlatform.instance = _FakeNotificationsPlatform();

      final db = AppDatabase(NativeDatabase.memory());
      await db.restoreDefaultTimetable();
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TimetableScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Edit timetable'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(ListTile).first);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField).first, 'Changed title');
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Save'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
      handle.dispose();
    },
  );
}
