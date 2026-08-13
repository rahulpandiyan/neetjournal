import 'package:flutter_test/flutter_test.dart';
import 'package:neet_journal/core/utils/dates.dart';

void main() {
  test('daysUntil counts inclusive of start day', () {
    final from = DateTime(2026, 8, 12);
    final to = DateTime(2027, 5, 2);
    expect(daysUntil(from, to), 263);
  });

  test('daysUntil is negative for past dates', () {
    expect(daysUntil(DateTime(2026, 9, 1), DateTime(2026, 8, 12)), lessThan(0));
  });

  test('timeOfDay formats 12-hour with AM/PM', () {
    expect(timeOfDay(3 * 60), '3:00 AM');
    expect(timeOfDay(3 * 60 + 15), '3:15 AM');
    expect(timeOfDay(21 * 60), '9:00 PM');
    expect(timeOfDay(12 * 60), '12:00 PM');
    expect(timeOfDay(0), '12:00 AM');
  });

  test('dateToStr / strToDate round-trip', () {
    final d = DateTime(2026, 8, 12);
    expect(dateToStr(d), '2026-08-12');
    expect(strToDate('2026-08-12'), d);
  });

  test('minutesSinceMidnight', () {
    expect(minutesSinceMidnight(DateTime(2026, 8, 12, 3, 15)), 195);
  });

  test('greetingFor', () {
    expect(greetingFor(DateTime(2026, 8, 12, 7)), 'Good Morning');
    expect(greetingFor(DateTime(2026, 8, 12, 14)), 'Good Afternoon');
    expect(greetingFor(DateTime(2026, 8, 12, 19)), 'Good Evening');
    expect(greetingFor(DateTime(2026, 8, 12, 23)), 'Good Night');
    expect(greetingFor(DateTime(2026, 8, 12, 3)), 'Late night');
  });
}
