import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../utils/dates.dart';
import '../../data/seed/chapters_seed.dart';
import '../../data/seed/timetable_seed.dart';
import 'tables.dart';

part 'database.g.dart';

/// Default NEET 2027 exam date (configurable via settings).
const String defaultExamDate = '2027-05-02';

@DriftDatabase(
  tables: [
    Subjects,
    Chapters,
    TimetableSlots,
    StudySessions,
    JournalEntries,
    PendingTasks,
    Tests,
    TestMistakes,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [executor] is injected in tests (e.g. an in-memory database); the app
  /// uses the on-device drift database by default.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'neet_journal'));

  @override
  int get schemaVersion => 2;

  /// Seeds subjects, chapters, the default timetable and default settings.
  /// Runs inside the first successful migration so fresh installs are ready.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tests);
        await m.createTable(testMistakes);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) return;
    },
  );

  Future<void> _seed() async {
    await _seedSubjectsAndChapters();
    await _seedTimetable();
    await _seedSettings();
  }

  Future<void> _seedSubjectsAndChapters() async {
    final colors = const <String, int>{
      'Physics': 0xFF1565C0,
      'Chemistry': 0xFF2E7D32,
      'Biology': 0xFF6A1B9A,
    };
    var order = 0;
    for (final entry in chaptersBySubject.entries) {
      final subjectId = await into(subjects).insertReturning(
        SubjectsCompanion.insert(
          name: entry.key,
          colorValue: colors[entry.key] ?? 0xFF37474F,
          sortOrder: Value(order++),
        ),
      );
      await batch((b) {
        b.insertAll(chapters, [
          for (final name in entry.value)
            ChaptersCompanion.insert(
              subjectId: subjectId.id,
              name: name,
              status: ChapterStatus.todo,
            ),
        ]);
      });
    }
  }

  Future<void> _seedTimetable() async {
    final subjectRows = await (select(subjects)).get();
    final byName = {for (final s in subjectRows) s.name: s.id};
    final physicsId = byName['Physics']!;
    final chemistryId = byName['Chemistry']!;
    final biologyId = byName['Biology']!;

    final weekday = buildWeekdaySlots(
      physicsId: physicsId,
      chemistryId: chemistryId,
      biologyId: biologyId,
    );
    final sunday = buildSundaySlots(
      physicsId: physicsId,
      chemistryId: chemistryId,
      biologyId: biologyId,
    );

    await batch((b) {
      // weekday is contiguous Monday→Saturday: first _slotsPerDay entries are
      // Monday, the next _slotsPerDay are Tuesday, and so on.
      const slotsPerDay = _slotsPerDay;
      for (var day = 0; day < 6; day++) {
        for (var i = 0; i < slotsPerDay; i++) {
          final spec = weekday[day * slotsPerDay + i];
          b.insert(
            timetableSlots,
            TimetableSlotsCompanion.insert(
              dayOfWeek: Value(day + 1),
              date: const Value(null),
              templateSlotId: const Value(null),
              startMin: spec.startMin,
              endMin: spec.endMin,
              subjectId: Value(spec.subjectId),
              activityType: spec.type,
              title: spec.title,
              target: Value(spec.target),
              isRecurring: true,
              isOptional: Value(spec.isOptional),
            ),
          );
        }
      }
      for (final spec in sunday) {
        b.insert(
          timetableSlots,
          TimetableSlotsCompanion.insert(
            dayOfWeek: const Value(kSunday),
            date: const Value(null),
            templateSlotId: const Value(null),
            startMin: spec.startMin,
            endMin: spec.endMin,
            subjectId: Value(spec.subjectId),
            activityType: spec.type,
            title: spec.title,
            target: Value(spec.target),
            isRecurring: true,
            isOptional: Value(spec.isOptional),
          ),
        );
      }
    });
  }

  static const int _slotsPerDay = 13;

  Future<void> _seedSettings() async {
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'examDate', value: defaultExamDate),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'focusMinutes', value: '50'),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'breakMinutes', value: '10'),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'focusPreset', value: '50/10'),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'waterReminderEnabled', value: '1'),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'waterReminderMinutes', value: '30'),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'studyRemindersEnabled', value: '1'),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: 'sleepReminderEnabled', value: '1'),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// The configured exam date, defaulting to NEET 2027.
  Future<DateTime> examDate() async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals('examDate'))).getSingleOrNull();
    return row == null ? strToDate(defaultExamDate) : strToDate(row.value);
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Wipes the timetable (template and one-offs) and reseeds the default.
  Future<void> restoreDefaultTimetable() async {
    await delete(timetableSlots).go();
    await _seedTimetable();
  }
}
