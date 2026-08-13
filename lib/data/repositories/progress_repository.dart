import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../core/utils/dates.dart';

/// Aggregate statistics for a week window.
class WeekStats {
  const WeekStats({
    required this.sessionsCompleted,
    required this.questionsSolved,
    required this.revisionSessions,
    required this.focusMinutes,
    required this.dailyFocus,
    required this.chaptersLearned,
  });

  final int sessionsCompleted;
  final int questionsSolved;
  final int revisionSessions;
  final int focusMinutes;

  /// Focus minutes per day of week (1=Mon..7=Sun).
  final Map<int, int> dailyFocus;
  final int chaptersLearned;
}

/// Revision spacing in days after learning a chapter (PRD §24).
const revisionSchedule = <int, String>{
  1: 'Quick Revision',
  3: 'Questions + PYQs',
  7: 'Weekly Revision',
  14: 'Second Revision',
  30: 'Monthly Revision',
};

class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  Future<List<Chapter>> chaptersForSubject(int subjectId) {
    return (_db.select(_db.chapters)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Marks a chapter learned/todo and keeps its revision schedule in sync:
  /// learning schedules Day 1/3/7/14/30 revision tasks; unlearning marks any
  /// open revision tasks for the chapter as skipped.
  Future<void> setChapterStatus(Chapter chapter, ChapterStatus status) async {
    await (_db.update(_db.chapters)..where((t) => t.id.equals(chapter.id)))
        .write(ChaptersCompanion(status: Value(status)));
    if (status == ChapterStatus.learned) {
      await scheduleRevision(chapter);
    } else {
      await cancelRevision(chapter);
    }
  }

  Future<void> scheduleRevision(Chapter chapter) async {
    final due = DateTime.now();
    for (final entry in revisionSchedule.entries) {
      final description =
          'Revise "${chapter.name}" — Day ${entry.key} ${entry.value}';
      final existing =
          await (_db.select(_db.pendingTasks)..where(
                (t) =>
                    t.description.equals(description) &
                    t.status.equalsValue(PendingStatus.pending),
              ))
              .get();
      if (existing.isNotEmpty) continue;
      await _db
          .into(_db.pendingTasks)
          .insert(
            PendingTasksCompanion.insert(
              subjectId: Value(chapter.subjectId),
              description: description,
              dueDate: dateToStr(due.add(Duration(days: entry.key))),
              source: Value('revision'),
              status: PendingStatus.pending,
              createdAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> cancelRevision(Chapter chapter) async {
    await (_db.update(_db.pendingTasks)..where(
          (t) =>
              t.source.equals('revision') &
              t.description.contains('Revise "${chapter.name}"') &
              t.status.equalsValue(PendingStatus.pending),
        ))
        .write(
          PendingTasksCompanion(
            status: Value(PendingStatus.skipped),
            completedAt: const Value(null),
          ),
        );
  }

  /// Stats for the current week (Monday up to today). Re-emits on any
  /// change to sessions, chapters or pending tasks.
  Stream<WeekStats> watchWeekStats() {
    return Stream.multi((controller) {
      var closed = false;
      Future<void> emit() async {
        if (closed) return;
        controller.add(await _computeWeekStats());
      }

      final sub = _db
          .tableUpdates(TableUpdateQuery.any())
          .listen((_) => emit());
      controller.onCancel = () {
        closed = true;
        sub.cancel();
      };
      emit();
    });
  }

  Future<WeekStats> _computeWeekStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));

    final sessions =
        await (_db.select(_db.studySessions)..where(
              (t) =>
                  t.date.isBetweenValues(dateToStr(monday), dateToStr(today)),
            ))
            .get();

    var sessionsCompleted = 0;
    var questionsSolved = 0;
    var revisionSessions = 0;
    var focusMinutes = 0;
    final dailyFocus = <int, int>{};

    for (final s in sessions) {
      dailyFocus.update(
        s.startedAt.weekday,
        (v) => v + s.focusMinutes,
        ifAbsent: () => s.focusMinutes,
      );
      if (s.status != SessionStatus.completed) continue;
      sessionsCompleted++;
      questionsSolved += s.questionsSolved;
      focusMinutes += s.focusMinutes;
      if (s.title.toLowerCase().contains('revision')) revisionSessions++;
    }

    final chapterRows = await (_db.select(_db.chapters)).get();
    final chaptersLearned = chapterRows
        .where((c) => c.status == ChapterStatus.learned)
        .length;

    return WeekStats(
      sessionsCompleted: sessionsCompleted,
      questionsSolved: questionsSolved,
      revisionSessions: revisionSessions,
      focusMinutes: focusMinutes,
      dailyFocus: dailyFocus,
      chaptersLearned: chaptersLearned,
    );
  }
}
