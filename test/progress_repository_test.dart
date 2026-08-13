import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neet_journal/core/db/database.dart';
import 'package:neet_journal/core/db/tables.dart';
import 'package:neet_journal/core/utils/dates.dart';
import 'package:neet_journal/data/repositories/progress_repository.dart';
import 'package:neet_journal/data/repositories/session_repository.dart';

void main() {
  late AppDatabase db;
  late ProgressRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('learning a chapter schedules Day 1/3/7/14/30 revision tasks', () async {
    final subject = (await db.select(db.subjects).get()).first;
    final chapter = (await repo.chaptersForSubject(subject.id)).first;

    await repo.setChapterStatus(chapter, ChapterStatus.learned);

    final revisionTasks =
        await (db.select(db.pendingTasks)..where(
              (t) =>
                  t.source.equals('revision') &
                  t.status.equalsValue(PendingStatus.pending),
            ))
            .get();

    expect(revisionTasks, hasLength(5));
    final dueDays = revisionTasks
        .map((t) => daysUntil(DateTime.now(), strToDate(t.dueDate)))
        .toSet();
    expect(dueDays, {1, 3, 7, 14, 30});
  });

  test('unlearning a chapter skips its open revision tasks', () async {
    final subject = (await db.select(db.subjects).get()).first;
    final chapter = (await repo.chaptersForSubject(subject.id)).first;

    await repo.setChapterStatus(chapter, ChapterStatus.learned);
    await repo.setChapterStatus(chapter, ChapterStatus.todo);

    final open = await (db.select(
      db.pendingTasks,
    )..where((t) => t.status.equalsValue(PendingStatus.pending))).get();
    final skipped = await (db.select(
      db.pendingTasks,
    )..where((t) => t.status.equalsValue(PendingStatus.skipped))).get();

    expect(open, isEmpty);
    expect(skipped, hasLength(5));
  });

  test('re-learning does not duplicate revision tasks', () async {
    final subject = (await db.select(db.subjects).get()).first;
    final chapter = (await repo.chaptersForSubject(subject.id)).first;

    await repo.setChapterStatus(chapter, ChapterStatus.learned);
    await repo.setChapterStatus(chapter, ChapterStatus.todo);
    await repo.setChapterStatus(chapter, ChapterStatus.learned);

    final all = await db.select(db.pendingTasks).get();
    expect(all, hasLength(10)); // 5 skipped + 5 pending
    final pending = all
        .where((t) => t.status == PendingStatus.pending)
        .toList();
    expect(pending, hasLength(5));
  });

  test('weekly stats aggregate completed sessions', () async {
    final subject = (await db.select(db.subjects).get()).first;
    final sessionRepo = SessionRepository(db);

    await sessionRepo.record(
      subjectId: subject.id,
      activityType: ActivityType.study,
      title: 'Physics MCQs',
      startedAt: DateTime.now(),
      endedAt: DateTime.now().add(const Duration(minutes: 50)),
      status: SessionStatus.completed,
      questionsSolved: 20,
      focusMinutes: 50,
    );

    final stats = await repo.watchWeekStats().first;

    expect(stats.sessionsCompleted, 1);
    expect(stats.questionsSolved, 20);
    expect(stats.focusMinutes, 50);
    expect(stats.dailyFocus[DateTime.now().weekday], 50);
  });
}
