import 'package:flutter_test/flutter_test.dart';
import 'package:neet_journal/core/db/tables.dart';
import 'package:neet_journal/data/seed/timetable_seed.dart';

void main() {
  const p = 1;
  const c = 2;
  const b = 3;

  group('weekday template', () {
    final slots = buildWeekdaySlots(
      physicsId: p,
      chemistryId: c,
      biologyId: b,
    );

    test('has exactly 13 slots per day for 6 days', () {
      expect(slots.length, 13 * 6);
    });

    test('each day starts with wake and ends with sleep', () {
      for (var day = 0; day < 6; day++) {
        final daySlots = slots.sublist(day * 13, day * 13 + 13);
        expect(daySlots.first.type, ActivityType.wake);
        expect(daySlots.last.type, ActivityType.sleep);
      }
    });

    test('Monday morning starts with Physics new concept', () {
      final monday = slots.sublist(0, 13);
      expect(monday[1].subjectId, p);
      expect(monday[1].title, contains('New Concept'));
      expect(monday[2].subjectId, c);
    });

    test('Monday evening is Physics MCQs then Biology NCERT recall', () {
      final monday = slots.sublist(0, 13);
      expect(monday[5].title, contains('MCQs / PYQs'));
      expect(monday[5].subjectId, p);
      expect(monday[6].title, contains('NCERT Recall'));
      expect(monday[6].subjectId, b);
    });

    test('Saturday includes weakest-area slot', () {
      final saturday = slots.sublist(5 * 13, 6 * 13);
      expect(saturday.any((s) => s.title == 'Weakest Area'), isTrue);
    });

    test('a break sits between the third study block and breakfast', () {
      final monday = slots.sublist(0, 13);
      expect(monday[4].type, ActivityType.breakActivity);
      expect(monday[3].type, ActivityType.study);
    });
  });

  group('sunday template', () {
    final sunday = buildSundaySlots(
      physicsId: p,
      chemistryId: c,
      biologyId: b,
    );

    test('contains weekly planning and sleep', () {
      expect(
        sunday.any((s) => s.type == ActivityType.planning),
        isTrue,
      );
      expect(sunday.last.type, ActivityType.sleep);
      expect(sunday.last.startMin, 22 * 60);
    });

    test('study-like items are optional', () {
      for (final s in sunday.where((s) => s.type.isStudyLike)) {
        expect(s.isOptional, isTrue,
            reason: '${s.title} should be optional on Sunday');
      }
    });

    test('planning is the only non-optional commitment', () {
      for (final s in sunday) {
        if (s.type.isStudyLike && !s.isOptional) {
          fail('${s.title} must be optional');
        }
      }
    });
  });
}
