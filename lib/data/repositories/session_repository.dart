import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../core/utils/dates.dart';

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<int> record({
    int? slotId,
    int? subjectId,
    required ActivityType activityType,
    required String title,
    required DateTime startedAt,
    DateTime? endedAt,
    required SessionStatus status,
    String? learned,
    String? pendingNote,
    int questionsSolved = 0,
    int focusMinutes = 0,
  }) {
    return _db
        .into(_db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            slotId: Value(slotId),
            subjectId: Value(subjectId),
            activityType: activityType,
            title: title,
            date: dateToStr(startedAt),
            startedAt: startedAt,
            endedAt: Value(endedAt),
            status: status,
            learned: Value(learned),
            pendingNote: Value(pendingNote),
            questionsSolved: Value(questionsSolved),
            focusMinutes: Value(focusMinutes),
          ),
        );
  }

  /// Sessions recorded for a given day, keyed by slot id.
  Future<Map<int, StudySession>> sessionsForDayBySlot(DateTime day) async {
    final rows = await (_db.select(
      _db.studySessions,
    )..where((t) => t.date.equals(dateToStr(day)))).get();
    return {
      for (final s in rows)
        if (s.slotId != null) s.slotId!: s,
    };
  }

  Future<List<StudySession>> sessionsBetween(DateTime from, DateTime to) async {
    final fromStr = dateToStr(from);
    final toStr = dateToStr(to);
    return (_db.select(
      _db.studySessions,
    )..where((t) => t.date.isBetweenValues(fromStr, toStr))).get();
  }

  Stream<List<StudySession>> watchSessionsBetween(DateTime from, DateTime to) {
    final fromStr = dateToStr(from);
    final toStr = dateToStr(to);
    return (_db.select(
      _db.studySessions,
    )..where((t) => t.date.isBetweenValues(fromStr, toStr))).watch();
  }
}
