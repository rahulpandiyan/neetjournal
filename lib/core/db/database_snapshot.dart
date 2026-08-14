import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

/// A full, serializable copy of the on-device database. Cloud sync works at
/// the whole-DB level: one Firestore doc holds the snapshot, devices pull it
/// on login and push it whenever local data changes.
class DatabaseSnapshot {
  DatabaseSnapshot({
    required this.subjects,
    required this.chapters,
    required this.timetableSlots,
    required this.studySessions,
    required this.journalEntries,
    required this.pendingTasks,
    required this.tests,
    required this.testMistakes,
    required this.appSettings,
  });

  final List<Subject> subjects;
  final List<Chapter> chapters;
  final List<TimetableSlot> timetableSlots;
  final List<StudySession> studySessions;
  final List<JournalEntry> journalEntries;
  final List<PendingTask> pendingTasks;
  final List<Test> tests;
  final List<TestMistake> testMistakes;
  final List<AppSetting> appSettings;
}

/// Pure row <-> JSON codecs (drift-generated rows don't serialize themselves).
/// JSON stays mirror-compatible with the drift column names so nothing else
/// needs to know about them.
class SubjectRowCodec {
  static Map<String, Object?> toJson(Subject r) => <String, Object?>{
    'id': r.id,
    'name': r.name,
    'colorValue': r.colorValue,
    'sortOrder': r.sortOrder,
  };

  static Subject fromJson(Map<String, Object?> j) => Subject(
    id: j['id'] as int,
    name: j['name'] as String,
    colorValue: j['colorValue'] as int,
    sortOrder: j['sortOrder'] as int,
  );
}

class ChapterRowCodec {
  static Map<String, Object?> toJson(Chapter r) => <String, Object?>{
    'id': r.id,
    'subjectId': r.subjectId,
    'name': r.name,
    'status': r.status.name,
  };

  static Chapter fromJson(Map<String, Object?> j) => Chapter(
    id: j['id'] as int,
    subjectId: j['subjectId'] as int,
    name: j['name'] as String,
    status: ChapterStatus.values.byName(j['status'] as String),
  );
}

class TimetableSlotRowCodec {
  static Map<String, Object?> toJson(TimetableSlot r) => <String, Object?>{
    'id': r.id,
    'dayOfWeek': r.dayOfWeek,
    'date': r.date,
    'templateSlotId': r.templateSlotId,
    'startMin': r.startMin,
    'endMin': r.endMin,
    'subjectId': r.subjectId,
    'activityType': r.activityType.name,
    'title': r.title,
    'target': r.target,
    'isRecurring': r.isRecurring,
    'isOptional': r.isOptional,
  };

  static TimetableSlot fromJson(Map<String, Object?> j) => TimetableSlot(
    id: j['id'] as int,
    dayOfWeek: j['dayOfWeek'] as int?,
    date: j['date'] as String?,
    templateSlotId: j['templateSlotId'] as int?,
    startMin: j['startMin'] as int,
    endMin: j['endMin'] as int,
    subjectId: j['subjectId'] as int?,
    activityType: ActivityType.values.byName(j['activityType'] as String),
    title: j['title'] as String,
    target: j['target'] as String?,
    isRecurring: j['isRecurring'] as bool,
    isOptional: j['isOptional'] as bool? ?? false,
  );
}

class StudySessionRowCodec {
  static Map<String, Object?> toJson(StudySession r) => <String, Object?>{
    'id': r.id,
    'slotId': r.slotId,
    'subjectId': r.subjectId,
    'activityType': r.activityType.name,
    'title': r.title,
    'date': r.date,
    'startedAt': r.startedAt.toUtc().toIso8601String(),
    'endedAt': r.endedAt?.toUtc().toIso8601String(),
    'status': r.status.name,
    'learned': r.learned,
    'pendingNote': r.pendingNote,
    'questionsSolved': r.questionsSolved,
    'focusMinutes': r.focusMinutes,
  };

  static StudySession fromJson(Map<String, Object?> j) => StudySession(
    id: j['id'] as int,
    slotId: j['slotId'] as int?,
    subjectId: j['subjectId'] as int?,
    activityType: ActivityType.values.byName(j['activityType'] as String),
    title: j['title'] as String,
    date: j['date'] as String,
    startedAt: DateTime.parse(j['startedAt'] as String),
    endedAt: j['endedAt'] == null
        ? null
        : DateTime.parse(j['endedAt'] as String),
    status: SessionStatus.values.byName(j['status'] as String),
    learned: j['learned'] as String?,
    pendingNote: j['pendingNote'] as String?,
    questionsSolved: j['questionsSolved'] as int? ?? 0,
    focusMinutes: j['focusMinutes'] as int? ?? 0,
  );
}

class JournalEntryRowCodec {
  static Map<String, Object?> toJson(JournalEntry r) => <String, Object?>{
    'id': r.id,
    'date': r.date,
    'learnedText': r.learnedText,
    'mood': r.mood?.name,
    'reflection': r.reflection,
    'isComplete': r.isComplete,
  };

  static JournalEntry fromJson(Map<String, Object?> j) => JournalEntry(
    id: j['id'] as int,
    date: j['date'] as String,
    learnedText: j['learnedText'] as String? ?? '',
    mood: j['mood'] == null
        ? null
        : JournalMood.values.byName(j['mood'] as String),
    reflection: j['reflection'] as String?,
    isComplete: j['isComplete'] as bool? ?? false,
  );
}

class PendingTaskRowCodec {
  static Map<String, Object?> toJson(PendingTask r) => <String, Object?>{
    'id': r.id,
    'subjectId': r.subjectId,
    'description': r.description,
    'dueDate': r.dueDate,
    'source': r.source,
    'status': r.status.name,
    'createdAt': r.createdAt.toUtc().toIso8601String(),
    'completedAt': r.completedAt?.toUtc().toIso8601String(),
  };

  static PendingTask fromJson(Map<String, Object?> j) => PendingTask(
    id: j['id'] as int,
    subjectId: j['subjectId'] as int?,
    description: j['description'] as String,
    dueDate: j['dueDate'] as String,
    source: j['source'] as String? ?? 'manual',
    status: PendingStatus.values.byName(j['status'] as String),
    createdAt: DateTime.parse(j['createdAt'] as String),
    completedAt: j['completedAt'] == null
        ? null
        : DateTime.parse(j['completedAt'] as String),
  );
}

class TestRowCodec {
  static Map<String, Object?> toJson(Test r) => <String, Object?>{
    'id': r.id,
    'name': r.name,
    'date': r.date,
    'physicsScore': r.physicsScore,
    'chemistryScore': r.chemistryScore,
    'biologyScore': r.biologyScore,
    'totalScore': r.totalScore,
    'notes': r.notes,
  };

  static Test fromJson(Map<String, Object?> j) => Test(
    id: j['id'] as int,
    name: j['name'] as String,
    date: j['date'] as String,
    physicsScore: j['physicsScore'] as int,
    chemistryScore: j['chemistryScore'] as int,
    biologyScore: j['biologyScore'] as int,
    totalScore: j['totalScore'] as int,
    notes: j['notes'] as String?,
  );
}

class TestMistakeRowCodec {
  static Map<String, Object?> toJson(TestMistake r) => <String, Object?>{
    'id': r.id,
    'testId': r.testId,
    'subjectId': r.subjectId,
    'category': r.category.name,
    'description': r.description,
    'isRevisioned': r.isRevisioned,
    'createdAt': r.createdAt.toUtc().toIso8601String(),
  };

  static TestMistake fromJson(Map<String, Object?> j) => TestMistake(
    id: j['id'] as int,
    testId: j['testId'] as int,
    subjectId: j['subjectId'] as int?,
    category: MistakeCategory.values.byName(j['category'] as String),
    description: j['description'] as String,
    isRevisioned: j['isRevisioned'] as bool? ?? false,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

class AppSettingRowCodec {
  static Map<String, Object?> toJson(AppSetting r) => <String, Object?>{
    'key': r.key,
    'value': r.value,
  };

  static AppSetting fromJson(Map<String, Object?> j) =>
      AppSetting(key: j['key'] as String, value: j['value'] as String);
}

/// Serializes and restores whole-DB snapshots for cloud sync.
class DatabaseSnapshotCodec {
  DatabaseSnapshotCodec(this.db);

  final AppDatabase db;

  static const int currentVersion = 1;

  Future<Map<String, Object?>> captureJson() async {
    return encode(await capture());
  }

  Future<DatabaseSnapshot> capture() async {
    return DatabaseSnapshot(
      subjects: await db.select(db.subjects).get(),
      chapters: await db.select(db.chapters).get(),
      timetableSlots: await db.select(db.timetableSlots).get(),
      studySessions: await db.select(db.studySessions).get(),
      journalEntries: await db.select(db.journalEntries).get(),
      pendingTasks: await db.select(db.pendingTasks).get(),
      tests: await db.select(db.tests).get(),
      testMistakes: await db.select(db.testMistakes).get(),
      appSettings: await db.select(db.appSettings).get(),
    );
  }

  Map<String, Object?> encode(DatabaseSnapshot s) {
    return <String, Object?>{
      'version': currentVersion,
      'subjects': s.subjects.map(SubjectRowCodec.toJson).toList(),
      'chapters': s.chapters.map(ChapterRowCodec.toJson).toList(),
      'timetableSlots': s.timetableSlots
          .map(TimetableSlotRowCodec.toJson)
          .toList(),
      'studySessions': s.studySessions
          .map(StudySessionRowCodec.toJson)
          .toList(),
      'journalEntries': s.journalEntries
          .map(JournalEntryRowCodec.toJson)
          .toList(),
      'pendingTasks': s.pendingTasks.map(PendingTaskRowCodec.toJson).toList(),
      'tests': s.tests.map(TestRowCodec.toJson).toList(),
      'testMistakes': s.testMistakes.map(TestMistakeRowCodec.toJson).toList(),
      'appSettings': s.appSettings.map(AppSettingRowCodec.toJson).toList(),
    };
  }

  /// Replaces the entire database contents with [map] (mirror restore). Runs
  /// inside a single transaction so a crash never leaves a half-restored DB.
  Future<void> restore(Map<String, Object?> map) async {
    final decoded = decode(map);
    await db.transaction(() async {
      // Delete children before parents (foreign keys).
      await db.delete(db.testMistakes).go();
      await db.delete(db.studySessions).go();
      await db.delete(db.timetableSlots).go();
      await db.delete(db.pendingTasks).go();
      await db.delete(db.tests).go();
      await db.delete(db.journalEntries).go();
      await db.delete(db.chapters).go();
      await db.delete(db.subjects).go();
      await db.delete(db.appSettings).go();

      await db.batch((b) {
        for (final row in decoded.subjects) {
          b.insert(
            db.subjects,
            SubjectsCompanion(
              id: Value(row.id),
              name: Value(row.name),
              colorValue: Value(row.colorValue),
              sortOrder: Value(row.sortOrder),
            ),
          );
        }
        for (final row in decoded.chapters) {
          b.insert(
            db.chapters,
            ChaptersCompanion(
              id: Value(row.id),
              subjectId: Value(row.subjectId),
              name: Value(row.name),
              status: Value(row.status),
            ),
          );
        }
        for (final row in decoded.timetableSlots) {
          b.insert(
            db.timetableSlots,
            TimetableSlotsCompanion(
              id: Value(row.id),
              dayOfWeek: Value(row.dayOfWeek),
              date: Value(row.date),
              templateSlotId: Value(row.templateSlotId),
              startMin: Value(row.startMin),
              endMin: Value(row.endMin),
              subjectId: Value(row.subjectId),
              activityType: Value(row.activityType),
              title: Value(row.title),
              target: Value(row.target),
              isRecurring: Value(row.isRecurring),
              isOptional: Value(row.isOptional),
            ),
          );
        }
        for (final row in decoded.studySessions) {
          b.insert(
            db.studySessions,
            StudySessionsCompanion(
              id: Value(row.id),
              slotId: Value(row.slotId),
              subjectId: Value(row.subjectId),
              activityType: Value(row.activityType),
              title: Value(row.title),
              date: Value(row.date),
              startedAt: Value(row.startedAt),
              endedAt: Value(row.endedAt),
              status: Value(row.status),
              learned: Value(row.learned),
              pendingNote: Value(row.pendingNote),
              questionsSolved: Value(row.questionsSolved),
              focusMinutes: Value(row.focusMinutes),
            ),
          );
        }
        for (final row in decoded.journalEntries) {
          b.insert(
            db.journalEntries,
            JournalEntriesCompanion(
              id: Value(row.id),
              date: Value(row.date),
              learnedText: Value(row.learnedText),
              mood: Value(row.mood),
              reflection: Value(row.reflection),
              isComplete: Value(row.isComplete),
            ),
          );
        }
        for (final row in decoded.pendingTasks) {
          b.insert(
            db.pendingTasks,
            PendingTasksCompanion(
              id: Value(row.id),
              subjectId: Value(row.subjectId),
              description: Value(row.description),
              dueDate: Value(row.dueDate),
              source: Value(row.source),
              status: Value(row.status),
              createdAt: Value(row.createdAt),
              completedAt: Value(row.completedAt),
            ),
          );
        }
        for (final row in decoded.tests) {
          b.insert(
            db.tests,
            TestsCompanion(
              id: Value(row.id),
              name: Value(row.name),
              date: Value(row.date),
              physicsScore: Value(row.physicsScore),
              chemistryScore: Value(row.chemistryScore),
              biologyScore: Value(row.biologyScore),
              totalScore: Value(row.totalScore),
              notes: Value(row.notes),
            ),
          );
        }
        for (final row in decoded.testMistakes) {
          b.insert(
            db.testMistakes,
            TestMistakesCompanion(
              id: Value(row.id),
              testId: Value(row.testId),
              subjectId: Value(row.subjectId),
              category: Value(row.category),
              description: Value(row.description),
              isRevisioned: Value(row.isRevisioned),
              createdAt: Value(row.createdAt),
            ),
          );
        }
        for (final row in decoded.appSettings) {
          b.insert(
            db.appSettings,
            AppSettingsCompanion.insert(key: row.key, value: row.value),
          );
        }
      });
    });
  }

  /// Decodes [map] without touching the database (used by [restore]).
  DatabaseSnapshot decode(Map<String, Object?> map) {
    final version = map['version'] as int? ?? currentVersion;
    if (version != currentVersion) {
      throw UnsupportedError(
        'Snapshot version $version is not supported (expected '
        '$currentVersion).',
      );
    }
    return DatabaseSnapshot(
      subjects: (map['subjects'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(SubjectRowCodec.fromJson)
          .toList(),
      chapters: (map['chapters'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(ChapterRowCodec.fromJson)
          .toList(),
      timetableSlots: (map['timetableSlots'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(TimetableSlotRowCodec.fromJson)
          .toList(),
      studySessions: (map['studySessions'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(StudySessionRowCodec.fromJson)
          .toList(),
      journalEntries: (map['journalEntries'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(JournalEntryRowCodec.fromJson)
          .toList(),
      pendingTasks: (map['pendingTasks'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(PendingTaskRowCodec.fromJson)
          .toList(),
      tests: (map['tests'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(TestRowCodec.fromJson)
          .toList(),
      testMistakes: (map['testMistakes'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(TestMistakeRowCodec.fromJson)
          .toList(),
      appSettings: (map['appSettings'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(AppSettingRowCodec.fromJson)
          .toList(),
    );
  }
}
