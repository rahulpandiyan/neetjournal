import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/db/tables.dart';
import '../core/services/notifications_service.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/pending_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/test_repository.dart';
import '../data/repositories/timetable_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final timetableRepositoryProvider = Provider<TimetableRepository>(
  (ref) => TimetableRepository(ref.watch(databaseProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(databaseProvider)),
);

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => JournalRepository(ref.watch(databaseProvider)),
);

final pendingRepositoryProvider = Provider<PendingRepository>(
  (ref) => PendingRepository(ref.watch(databaseProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(databaseProvider)),
);

final testRepositoryProvider = Provider<TestRepository>(
  (ref) => TestRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => NotificationsService.instance,
);

final notificationPrefsProvider = StreamProvider<({bool study, bool sleep})>((
  ref,
) {
  return ref.watch(settingsRepositoryProvider).watchNotificationPrefs();
});

/// Rebuilds scheduled notifications from the weekly template + prefs.
Future<void> syncNotifications(WidgetRef ref) async {
  final service = ref.read(notificationsServiceProvider);
  final template = await ref.read(templateByDayProvider.future);
  final prefs = await ref.read(notificationPrefsProvider.future);
  await service.rescheduleFromTemplate(
    template: template,
    studyReminders: prefs.study,
    sleepReminder: prefs.sleep,
  );
}

final subjectsByIdProvider = FutureProvider<Map<int, Subject>>((ref) async {
  final repo = ref.watch(timetableRepositoryProvider);
  return repo.subjectsById();
});

final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return ref.watch(timetableRepositoryProvider).allSubjects();
});

final examDateProvider = StreamProvider<DateTime>((ref) {
  return ref.watch(settingsRepositoryProvider).watchExamDate();
});

final focusDurationsProvider = StreamProvider<(int, int)>((ref) {
  return ref.watch(settingsRepositoryProvider).watchFocusDurations();
});

final waterReminderProvider = StreamProvider<({bool enabled, int minutes})>((
  ref,
) {
  return ref.watch(settingsRepositoryProvider).watchWaterReminder();
});

final templateByDayProvider = StreamProvider<Map<int, List<TimetableSlot>>>((
  ref,
) {
  final repo = ref.watch(timetableRepositoryProvider);
  return repo.watchTemplate().map((rows) {
    final map = <int, List<TimetableSlot>>{};
    for (final r in rows) {
      map.putIfAbsent(r.dayOfWeek!, () => []).add(r);
    }
    return map;
  });
});

/// A single day's merged view: weekly template with that day's one-off
/// overrides (moves, Edit Today) applied.
final daySlotsProvider = StreamProvider.family<List<TimetableSlot>, DateTime>((
  ref,
  day,
) {
  return ref.watch(timetableRepositoryProvider).watchDay(day);
});

/// Per-subject chapter progress: (total, learned).
final chapterProgressProvider = StreamProvider<Map<int, (int, int)>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.chapters).watch().map((rows) {
    final map = <int, (int, int)>{};
    for (final c in rows) {
      final cur = map[c.subjectId] ?? (0, 0);
      map[c.subjectId] = (
        cur.$1 + 1,
        cur.$2 + (c.status == ChapterStatus.learned ? 1 : 0),
      );
    }
    return map;
  });
});

/// Chapters grouped by subject, in seed order.
final chaptersBySubjectProvider = StreamProvider<Map<int, List<Chapter>>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return db.select(db.chapters).watch().map((rows) {
    final map = <int, List<Chapter>>{};
    for (final c in rows) {
      map.putIfAbsent(c.subjectId, () => []).add(c);
    }
    return map;
  });
});

/// Live aggregate stats for the current week.
final weekStatsProvider = StreamProvider<WeekStats>((ref) {
  return ref.watch(progressRepositoryProvider).watchWeekStats();
});

/// All recorded mock tests, newest first.
final testsProvider = StreamProvider<List<Test>>((ref) {
  return ref.watch(testRepositoryProvider).watchTests();
});

/// Mistakes recorded against a single test.
final testMistakesProvider = StreamProvider.family<List<TestMistake>, int>((
  ref,
  testId,
) {
  return ref.watch(testRepositoryProvider).watchMistakes(testId);
});

final journalTodayProvider = StreamProvider<JournalEntry?>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchEntryForDate(DateTime.now());
});

final journalHistoryProvider = FutureProvider<List<JournalEntry>>((ref) {
  return ref.watch(journalRepositoryProvider).history();
});

/// Open pending tasks due today or overdue (used by Today + Journal).
final openPendingProvider = StreamProvider<List<PendingTask>>((ref) {
  return ref
      .watch(pendingRepositoryProvider)
      .watchOpenDueOnOrBefore(DateTime.now());
});

/// All open pending tasks, including future-dated revision tasks.
final allPendingProvider = StreamProvider<List<PendingTask>>((ref) {
  return ref.watch(pendingRepositoryProvider).watchAllPending();
});

final todaySessionsProvider = StreamProvider<List<StudySession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessionsBetween(DateTime.now(), DateTime.now());
});

/// A stream that emits immediately, on any database change, and on a periodic
/// tick so "now"-based UI (NOW/NEXT, countdown) stays fresh.
Stream<Object?> dbTickStream(AppDatabase db) {
  return Stream.multi((controller) {
    var closed = false;
    void emit() {
      if (!closed) controller.add(null);
    }

    final timer = Timer.periodic(const Duration(seconds: 20), (_) => emit());
    late final StreamSubscription sub;
    sub = db.tableUpdates(TableUpdateQuery.any()).listen((_) => emit());
    controller.onCancel = () {
      closed = true;
      timer.cancel();
      sub.cancel();
    };
    emit();
  });
}
