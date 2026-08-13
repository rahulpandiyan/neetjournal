import 'package:flutter_test/flutter_test.dart';

import 'package:neet_journal/core/db/database.dart';
import 'package:neet_journal/core/db/tables.dart';
import 'package:neet_journal/core/services/notifications_service.dart';
import 'package:neet_journal/core/utils/dates.dart';

TimetableSlot slot({
  required int id,
  required int startMin,
  required int endMin,
  required ActivityType type,
  required String title,
}) {
  return TimetableSlot(
    id: id,
    startMin: startMin,
    endMin: endMin,
    activityType: type,
    title: title,
    isRecurring: true,
    isOptional: false,
  );
}

const allOn = (
  study: true,
  rest: true,
  revision: true,
  sleep: true,
  morning: true,
);

void main() {
  final examDate = DateTime(2027, 5, 2);

  final monday = [
    slot(
      id: 1,
      startMin: 5 * 60,
      endMin: 5 * 60,
      type: ActivityType.wake,
      title: 'Wake up',
    ),
    slot(
      id: 2,
      startMin: 315,
      endMin: 375,
      type: ActivityType.study,
      title: 'Physics — New Concept',
    ),
    slot(
      id: 3,
      startMin: 375,
      endMin: 390,
      type: ActivityType.breakActivity,
      title: 'Break',
    ),
    slot(
      id: 4,
      startMin: 390,
      endMin: 450,
      type: ActivityType.study,
      title: 'Chemistry — Questions',
    ),
    slot(
      id: 5,
      startMin: 22 * 60,
      endMin: 22 * 60,
      type: ActivityType.sleep,
      title: 'Sleep',
    ),
  ];

  test('full rhythm for a study day is derived from the template', () {
    final specs = buildWeeklySpecs(
      template: {1: monday},
      prefs: allOn,
      examDate: examDate,
    );

    bool has(String title, String body, int hour, int minute) => specs.any(
      (s) =>
          s.title == title &&
          s.body == body &&
          s.hour == hour &&
          s.minute == minute,
    );

    expect(specs.map((s) => s.dayOfWeek), everyElement(1));
    expect(
      has(
        'Good morning ☀️',
        'NEET 2027 — ${daysUntil(DateTime.now(), examDate)} days left. Stay consistent.',
        5,
        0,
      ),
      isTrue,
    );
    // pre-start nudge for the first study slot
    expect(
      has(
        'Good morning ☀️',
        'NEET 2027 — ${daysUntil(DateTime.now(), examDate)} days left. Stay consistent.',
        5,
        0,
      ),
      isTrue,
    );
    // first study slot: "Time to study"
    expect(
      has(
        'Time to study',
        'Physics — New Concept is up. Stay consistent.',
        5,
        15,
      ),
      isTrue,
    );
    // later study slot: "Break over"
    expect(
      has(
        'Break over',
        'Chemistry — Questions is next. Get back to it.',
        6,
        30,
      ),
      isTrue,
    );
    // session end: take a break
    expect(
      has(
        'Session complete',
        'Physics — New Concept complete. Take a break. Drink water, stretch.',
        6,
        15,
      ),
      isTrue,
    );
    expect(
      has(
        'Session complete',
        'Chemistry — Questions complete. Take a break. Drink water, stretch.',
        7,
        30,
      ),
      isTrue,
    );
    // night journal reminder an hour before bed + sleep
    expect(
      has(
        'Your study day is almost complete',
        'Finish your journal and prepare for tomorrow.',
        21,
        0,
      ),
      isTrue,
    );
    expect(
      has('Time to sleep', 'Rest well. Reset and start tomorrow fresh.', 22, 0),
      isTrue,
    );
  });

  test('pre-start nudge is skipped when it would wrap to the previous day', () {
    final predawnStudy = [
      slot(
        id: 1,
        startMin: 5,
        endMin: 60,
        type: ActivityType.study,
        title: 'Physics',
      ),
    ];
    final specs = buildWeeklySpecs(
      template: {2: predawnStudy},
      prefs: allOn,
      examDate: examDate,
    );

    expect(specs.where((s) => s.title == 'Starting soon'), isEmpty);
    expect(specs.any((s) => s.title == 'Time to study'), isTrue);
  });

  test('each notification category can be toggled off', () {
    final off = buildWeeklySpecs(
      template: {1: monday},
      prefs: (
        study: false,
        rest: false,
        revision: false,
        sleep: false,
        morning: false,
      ),
      examDate: examDate,
    );
    expect(off, isEmpty);

    final studyOnly = buildWeeklySpecs(
      template: {1: monday},
      prefs: (
        study: true,
        rest: false,
        revision: false,
        sleep: false,
        morning: false,
      ),
      examDate: examDate,
    );
    expect(studyOnly.any((s) => s.title == 'Time to study'), isTrue);
    expect(studyOnly.any((s) => s.title == 'Session complete'), isFalse);
    expect(studyOnly.any((s) => s.title == 'Time to sleep'), isFalse);
  });

  test('seenStudy resets per day', () {
    final tuesday = [
      slot(
        id: 6,
        startMin: 5 * 60,
        endMin: 5 * 60,
        type: ActivityType.wake,
        title: 'Wake up',
      ),
      slot(
        id: 7,
        startMin: 315,
        endMin: 375,
        type: ActivityType.study,
        title: 'Biology — NCERT',
      ),
    ];
    final specs = buildWeeklySpecs(
      template: {1: monday, 2: tuesday},
      prefs: allOn,
      examDate: examDate,
    );

    expect(
      specs.any((s) => s.dayOfWeek == 2 && s.title == 'Time to study'),
      isTrue,
    );
    // Monday's second study slot must be "Break over", not "Time to study".
    final mondayStudyStarts = specs.where(
      (s) => s.dayOfWeek == 1 && s.title == 'Time to study',
    );
    expect(mondayStudyStarts, hasLength(1));
  });
}
