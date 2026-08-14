import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/state/providers.dart';
import 'package:studyn/state/today_controller.dart';

void main() {
  test('todayProvider reflects setBadDay', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final sub = container.listen(todayProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final first = container.read(todayProvider).requireValue;
    expect(first.badDay, isFalse);

    final now = DateTime.now();
    await container.read(settingsRepositoryProvider).setBadDay(now, true);

    // Wait for the stream to re-emit after the DB write.
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    final second = container.read(todayProvider).requireValue;
    expect(second.badDay, isTrue, reason: 'bad day should toggle on');

    sub.close();
  });
}
