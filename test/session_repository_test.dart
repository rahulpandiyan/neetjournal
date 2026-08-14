import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/core/db/tables.dart';
import 'package:studyn/data/repositories/session_repository.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'record is idempotent per (slotId, startedAt): re-record updates',
    () async {
      final started = DateTime(2026, 8, 14, 9, 0, 5);

      await repo.record(
        slotId: 3,
        activityType: ActivityType.study,
        title: 'Mechanics',
        startedAt: started,
        endedAt: started.add(const Duration(minutes: 50)),
        status: SessionStatus.partial,
        focusMinutes: 50,
      );
      await repo.record(
        slotId: 3,
        activityType: ActivityType.study,
        title: 'Mechanics',
        startedAt: started,
        endedAt: started.add(const Duration(minutes: 50)),
        status: SessionStatus.completed,
        questionsSolved: 12,
        focusMinutes: 50,
      );

      final rows = await (db.select(
        db.studySessions,
      )..where((t) => t.slotId.equals(3))).get();
      expect(rows, hasLength(1));
      expect(rows.single.status, SessionStatus.completed);
      expect(rows.single.questionsSolved, 12);
    },
  );

  test(
    'a second session for the same slot at a different time is a new row',
    () async {
      final a = DateTime(2026, 8, 14, 9, 0, 0);
      final b = DateTime(2026, 8, 14, 11, 0, 0);

      await repo.record(
        slotId: 4,
        activityType: ActivityType.study,
        title: 'A',
        startedAt: a,
        status: SessionStatus.completed,
        focusMinutes: 50,
      );
      await repo.record(
        slotId: 4,
        activityType: ActivityType.study,
        title: 'B',
        startedAt: b,
        status: SessionStatus.completed,
        focusMinutes: 50,
      );

      final rows = await (db.select(
        db.studySessions,
      )..where((t) => t.slotId.equals(4))).get();
      expect(rows, hasLength(2));
    },
  );
}
