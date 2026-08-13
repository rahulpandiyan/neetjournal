import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../db/tables.dart';

/// Platform notification service: schedules the daily study rhythm
/// (study-start reminders per weekly template slot + a sleep reminder).
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

  /// Rebuilds the schedule from the weekly template.
  ///
  /// [template] is keyed by day-of-week (1=Mon..7=Sun) with the day's slots.
  /// Non-study slots (sleep) are used for the sleep reminder. Every study-like
  /// slot gets a "Time to study" nudge. Everything is cancelled first so edits
  /// to the timetable take effect on the next sync.
  Future<void> rescheduleFromTemplate({
    required Map<int, List<TimetableSlot>> template,
    required bool studyReminders,
    required bool sleepReminder,
  }) async {
    await init();
    await _plugin.cancelAll();

    var id = 100;
    for (final entry in template.entries) {
      final day = entry.key;
      final slots = entry.value;
      for (final slot in slots) {
        final start = slot.startMin;
        if (slot.activityType.isStudyLike && studyReminders) {
          await scheduleWeekly(
            id: id++,
            dayOfWeek: day,
            hour: start ~/ 60,
            minute: start % 60,
            title: 'Time to study',
            body: '${slot.title} is up. Stay consistent.',
          );
        } else if (slot.activityType == ActivityType.sleep && sleepReminder) {
          await scheduleWeekly(
            id: id++,
            dayOfWeek: day,
            hour: start ~/ 60,
            minute: start % 60,
            title: 'Time to sleep',
            body: 'Your study day is complete. Journal and rest.',
          );
        }
      }
    }
  }
}
