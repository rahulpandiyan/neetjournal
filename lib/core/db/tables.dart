import 'package:drift/drift.dart';

const int kMonday = 1;
const int kSunday = 7;

enum ActivityType {
  study,
  wake,
  breakActivity,
  meal,
  college,
  reset,
  sleep,
  recovery,
  planning,
  free;

  String get label {
    switch (this) {
      case ActivityType.study:
        return 'Study';
      case ActivityType.wake:
        return 'Wake up';
      case ActivityType.breakActivity:
        return 'Break';
      case ActivityType.meal:
        return 'Meal';
      case ActivityType.college:
        return 'College';
      case ActivityType.reset:
        return 'Reset';
      case ActivityType.sleep:
        return 'Sleep';
      case ActivityType.recovery:
        return 'Recovery';
      case ActivityType.planning:
        return 'Planning';
      case ActivityType.free:
        return 'Free';
    }
  }

  bool get isStudyLike =>
      this == ActivityType.study || this == ActivityType.recovery;
}

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get colorValue => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

enum ChapterStatus { todo, learned }

class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get status => textEnum<ChapterStatus>()();
}

class TimetableSlots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Weekly template: day of week (1=Mon..7=Sun). Null for pure one-off slots.
  IntColumn get dayOfWeek => integer().nullable()();

  /// One-off (Edit Today / moved) slots have a concrete date. Null for template.
  TextColumn get date => text().nullable()();

  /// For one-off slots that replace a template slot: links to the template slot id.
  IntColumn get templateSlotId => integer().nullable()();

  IntColumn get startMin => integer()();
  IntColumn get endMin => integer()();

  IntColumn get subjectId => integer().references(Subjects, #id).nullable()();
  TextColumn get activityType => textEnum<ActivityType>()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get target => text().nullable()();

  /// Whether this row is part of the weekly template (recurring every week).
  BoolColumn get isRecurring => boolean()();

  /// Sunday recovery items are optional.
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
}

enum SessionStatus { completed, partial, notCompleted }

class StudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get slotId => integer().nullable()();
  IntColumn get subjectId => integer().nullable()();
  TextColumn get activityType => textEnum<ActivityType>()();
  TextColumn get title => text()();
  TextColumn get date => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => textEnum<SessionStatus>()();
  TextColumn get learned => text().nullable()();
  TextColumn get pendingNote => text().nullable()();
  IntColumn get questionsSolved => integer().withDefault(const Constant(0))();
  IntColumn get focusMinutes => integer().withDefault(const Constant(0))();
}

enum JournalMood { difficult, okay, good, excellent }

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().unique()();
  TextColumn get learnedText => text().withDefault(const Constant(''))();
  TextColumn get mood => textEnum<JournalMood>().nullable()();
  TextColumn get reflection => text().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
}

enum PendingStatus { pending, done, skipped }

class PendingTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id).nullable()();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  TextColumn get dueDate => text()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get status => textEnum<PendingStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Tests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get date => text()();
  IntColumn get physicsScore => integer()();
  IntColumn get chemistryScore => integer()();
  IntColumn get biologyScore => integer()();
  IntColumn get totalScore => integer()();
  TextColumn get notes => text().nullable()();
}

enum MistakeCategory {
  conceptNotKnown,
  forgotConcept,
  calculation,
  misread,
  silly,
  guess,
}

extension MistakeCategoryLabel on MistakeCategory {
  String get label {
    switch (this) {
      case MistakeCategory.conceptNotKnown:
        return 'Concept not known';
      case MistakeCategory.forgotConcept:
        return 'Forgot concept';
      case MistakeCategory.calculation:
        return 'Calculation mistake';
      case MistakeCategory.misread:
        return 'Misread question';
      case MistakeCategory.silly:
        return 'Silly mistake';
      case MistakeCategory.guess:
        return 'Guess';
    }
  }
}

class TestMistakes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get testId => integer().references(Tests, #id)();
  IntColumn get subjectId => integer().references(Subjects, #id).nullable()();
  TextColumn get category => textEnum<MistakeCategory>()();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  BoolColumn get isRevisioned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
