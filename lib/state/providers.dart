import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/db/tables.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/pending_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/settings_repository.dart';
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

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

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

final journalTodayProvider = StreamProvider<JournalEntry?>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchEntryForDate(DateTime.now());
});

final journalHistoryProvider = FutureProvider<List<JournalEntry>>((ref) {
  return ref.watch(journalRepositoryProvider).history();
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
