import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/core/db/tables.dart';
import 'package:studyn/state/providers.dart';
import 'package:studyn/state/reminder_controller.dart';

void main() {
  // A fixed Friday at 09:00, with a study slot ending exactly at 09:00.
  final now = DateTime(2026, 8, 14, 9, 0);

  TimetableSlot studySlot() => TimetableSlot(
    id: 7,
    dayOfWeek: DateTime.friday,
    startMin: 8 * 60 + 50,
    endMin: 9 * 60,
    subjectId: 1,
    activityType: ActivityType.study,
    title: 'Physics',
    isRecurring: true,
    isOptional: false,
  );

  List<Override> stubs() => [
    daySlotsProvider.overrideWith(
      (ref, day) => Stream<List<TimetableSlot>>.value([studySlot()]),
    ),
  ];

  testWidgets('rest reminder fires when a study slot just ended', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final container = ProviderContainer(
      overrides: [
        ...stubs(),
        foregroundReminderProvider.overrideWith(
          () => ForegroundReminderController(now: () => now),
        ),
      ],
    );

    expect(container.read(foregroundReminderProvider), isNull);
    await tester.pump();

    final reminder = container.read(foregroundReminderProvider);
    expect(reminder, isNotNull);
    expect(reminder!.kind, 'rest');
    expect(reminder.body, contains('Physics'));

    // The same slot must not fire a second reminder.
    await tester.pump(const Duration(seconds: 20));
    expect(container.read(foregroundReminderProvider), same(reminder));

    container.dispose();
  });

  testWidgets('rest reminder does not fire when app is not resumed', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final container = ProviderContainer(
      overrides: [
        ...stubs(),
        foregroundReminderProvider.overrideWith(
          () => ForegroundReminderController(now: () => now),
        ),
      ],
    );

    container.read(foregroundReminderProvider);
    await tester.pump();
    await tester.pump(const Duration(seconds: 20));

    expect(container.read(foregroundReminderProvider), isNull);
    container.dispose();
  });
}
