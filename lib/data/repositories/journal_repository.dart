import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../core/utils/dates.dart';

class JournalRepository {
  JournalRepository(this._db);

  final AppDatabase _db;

  Future<JournalEntry?> entryForDate(DateTime day) async {
    return (_db.select(
      _db.journalEntries,
    )..where((t) => t.date.equals(dateToStr(day)))).getSingleOrNull();
  }

  Stream<JournalEntry?> watchEntryForDate(DateTime day) {
    return (_db.select(
      _db.journalEntries,
    )..where((t) => t.date.equals(dateToStr(day)))).watchSingleOrNull();
  }

  Future<List<JournalEntry>> history() {
    return (_db.select(
      _db.journalEntries,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  }

  Future<void> save({
    required DateTime day,
    String learnedText = '',
    JournalMood? mood,
    String? reflection,
    bool isComplete = false,
  }) async {
    final existing = await entryForDate(day);
    if (existing == null) {
      await _db
          .into(_db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              date: dateToStr(day),
              learnedText: Value(learnedText),
              mood: Value(mood),
              reflection: Value(reflection),
              isComplete: Value(isComplete),
            ),
          );
    } else {
      await (_db.update(
        _db.journalEntries,
      )..where((t) => t.date.equals(dateToStr(day)))).write(
        JournalEntriesCompanion(
          learnedText: Value(learnedText),
          mood: Value(mood),
          reflection: Value(reflection),
          isComplete: Value(isComplete),
        ),
      );
    }
  }
}
