import 'package:intl/intl.dart';

/// Format a date-only value as 'yyyy-MM-dd'.
String dateToStr(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Parse 'yyyy-MM-dd' back to a local midnight DateTime.
DateTime strToDate(String s) {
  final parts = s.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String timeOfDay(int minutesSinceMidnight) {
  final h = minutesSinceMidnight ~/ 60;
  final m = minutesSinceMidnight % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final hh = h % 12 == 0 ? 12 : h % 12;
  return '$hh:${m.toString().padLeft(2, '0')} $period';
}

int minutesSinceMidnight(DateTime t) => t.hour * 60 + t.minute;

/// Days from [from] (inclusive) until [to] (exclusive); positive if in the future.
int daysUntil(DateTime from, DateTime to) {
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

String greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 5) return 'Late night';
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  if (h < 21) return 'Good Evening';
  return 'Good Night';
}
