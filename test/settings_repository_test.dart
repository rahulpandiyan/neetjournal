import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/data/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('bad day mode is scoped to a single day', () async {
    final today = DateTime(2026, 8, 13);
    final tomorrow = today.add(const Duration(days: 1));

    expect(await repo.badDay(today), isFalse);

    await repo.setBadDay(today, true);

    expect(await repo.badDay(today), isTrue);
    expect(
      await repo.badDay(tomorrow),
      isFalse,
      reason: 'bad day should not leak into the next day',
    );
  });

  test('notification toggles default on and persist per category', () async {
    final prefs = await repo.watchNotificationPrefs().first;

    expect(prefs.study, isTrue);
    expect(prefs.rest, isTrue);
    expect(prefs.revision, isTrue);
    expect(prefs.sleep, isTrue);
    expect(prefs.morning, isTrue);

    await repo.setNotificationPrefs(rest: false, revision: false);

    final updated = await repo.watchNotificationPrefs().first;
    expect(updated.study, isTrue);
    expect(updated.rest, isFalse);
    expect(updated.revision, isFalse);
    expect(updated.sleep, isTrue);
    expect(updated.morning, isTrue);
  });

  test('stretch reminder defaults on at 25 minutes and persists', () async {
    final reminder = await repo.watchStretchReminder().first;
    expect(reminder.enabled, isTrue);
    expect(reminder.minutes, 25);

    await repo.setStretchReminder(false, 30);

    final updated = await repo.watchStretchReminder().first;
    expect(updated.enabled, isFalse);
    expect(updated.minutes, 30);
  });
}
