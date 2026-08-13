import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../db/tables.dart';
import '../utils/dates.dart';

/// Which notification categories the student has enabled.
typedef NotificationPrefs = ({
  bool study,
  bool rest,
  bool revision,
  bool sleep,
  bool morning,
});

/// Local time at which due-today revision reminders fire.
const int revisionReminderHour = 8;
const int revisionReminderMinute = 0;

/// Minutes before a study slot when the pre-start nudge fires.
const int preStartMinutes = 10;

/// Minutes before bedtime when the night journal reminder fires.
const int nightReminderMinutes = 60;

class NotificationSpec {
  const NotificationSpec({
    required this.id,
    required this.dayOfWeek,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });

  final int id;
  final int dayOfWeek;
  final int hour;
  final int minute;
  final String title;
  final String body;
}

/// Pure: derives the week's notification plan from the weekly template.
///
/// Rhythm per study slot: "starts in 10 minutes" → "Time to study" (first of
/// the day) / "Break over, X is next" (later slots) → "X complete, take a
/// break". Sleep slots also get a night journal reminder shortly before bed.
List<NotificationSpec> buildWeeklySpecs({
  required Map<int, List<TimetableSlot>> template,
  required NotificationPrefs prefs,
  required DateTime examDate,
}) {
  final specs = <NotificationSpec>[];
  var id = 100;
  final daysLeft = daysUntil(DateTime.now(), examDate);

  for (final entry in template.entries) {
    final day = entry.key;
    final slots = entry.value;
    var seenStudy = false;

    for (final slot in slots) {
      final start = slot.startMin;
      final end = slot.endMin;
      final isStudy = slot.activityType.isStudyLike;

      if (slot.activityType == ActivityType.wake && prefs.morning) {
        specs.add(
          NotificationSpec(
            id: id++,
            dayOfWeek: day,
            hour: start ~/ 60,
            minute: start % 60,
            title: 'Good morning ☀️',
            body: 'NEET 2027 — $daysLeft days left. Stay consistent.',
          ),
        );
      }

      if (isStudy) {
        if (prefs.study) {
          final preStart = start - preStartMinutes;
          if (preStart >= 0) {
            specs.add(
              NotificationSpec(
                id: id++,
                dayOfWeek: day,
                hour: preStart ~/ 60,
                minute: preStart % 60,
                title: 'Starting soon',
                body: '${slot.title} starts in $preStartMinutes minutes.',
              ),
            );
          }
          specs.add(
            NotificationSpec(
              id: id++,
              dayOfWeek: day,
              hour: start ~/ 60,
              minute: start % 60,
              title: seenStudy ? 'Break over' : 'Time to study',
              body: seenStudy
                  ? '${slot.title} is next. Get back to it.'
                  : '${slot.title} is up. Stay consistent.',
            ),
          );
          seenStudy = true;
        }
        if (prefs.rest) {
          specs.add(
            NotificationSpec(
              id: id++,
              dayOfWeek: day,
              hour: end ~/ 60,
              minute: end % 60,
              title: 'Session complete',
              body:
                  '${slot.title} complete. Take a break. Drink water, stretch.',
            ),
          );
        }
      }

      if (slot.activityType == ActivityType.sleep) {
        if (prefs.sleep) {
          final preBed = start - nightReminderMinutes;
          if (preBed >= 0) {
            specs.add(
              NotificationSpec(
                id: id++,
                dayOfWeek: day,
                hour: preBed ~/ 60,
                minute: preBed % 60,
                title: 'Your study day is almost complete',
                body: 'Finish your journal and prepare for tomorrow.',
              ),
            );
          }
          specs.add(
            NotificationSpec(
              id: id++,
              dayOfWeek: day,
              hour: start ~/ 60,
              minute: start % 60,
              title: 'Time to sleep',
              body: 'Rest well. Reset and start tomorrow fresh.',
            ),
          );
        }
      }
    }
  }

  return specs;
}

/// Platform notification service: schedules the daily study rhythm
/// (morning greeting, study/rest/sleep reminders from the weekly template)
/// and one-shot revision reminders for tasks due today.
class NotificationsService {
  NotificationsService._();

  static final NotificationsService instance = NotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'study_reminders',
      'Study reminders',
      channelDescription: 'Study, rest and sleep reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (_initialized) return;
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Requests notification permission (and asks the OS to keep alarms
  /// inexact, so no exact-alarm permission is required).
  Future<void> requestPermissions() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
  }

  Future<void> showImmediately({required String title, required String body}) {
    return _plugin.show(
      id: 9999,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Schedules a reminder that repeats every week at [dayOfWeek] and time.
  Future<void> scheduleWeekly({
    required int id,
    required int dayOfWeek,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    var daysAhead = (dayOfWeek - now.weekday) % 7;
    if (daysAhead == 0 && !scheduled.isAfter(now)) daysAhead = 7;
    scheduled = scheduled.add(Duration(days: daysAhead));
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduled,
      notificationDetails: _details,
      title: title,
      body: body,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedules a one-shot reminder for today at the given time.
  Future<void> scheduleOneShot({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduled,
      notificationDetails: _details,
      title: title,
      body: body,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Rebuilds the weekly rhythm from the template. Everything is cancelled
  /// first so timetable edits take effect on the next sync.
  Future<void> rescheduleFromTemplate({
    required Map<int, List<TimetableSlot>> template,
    required NotificationPrefs prefs,
    required DateTime examDate,
  }) async {
    await init();
    await _plugin.cancelAll();
    final specs = buildWeeklySpecs(
      template: template,
      prefs: prefs,
      examDate: examDate,
    );
    for (final spec in specs) {
      await scheduleWeekly(
        id: spec.id,
        dayOfWeek: spec.dayOfWeek,
        hour: spec.hour,
        minute: spec.minute,
        title: spec.title,
        body: spec.body,
      );
    }
  }

  /// Schedules one-shot revision reminders for tasks due today.
  Future<void> scheduleRevisionReminders(List<PendingTask> dueToday) async {
    await init();
    // Revision reminders live in the 1..99 id range.
    for (var id = 1; id <= 99; id++) {
      await _plugin.cancel(id: id);
    }
    var id = 1;
    for (final task in dueToday) {
      await scheduleOneShot(
        id: id++,
        hour: revisionReminderHour,
        minute: revisionReminderMinute,
        title: 'Revision due today',
        body: task.description,
      );
    }
  }
}
