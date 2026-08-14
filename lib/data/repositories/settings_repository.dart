import '../../core/db/database.dart';
import '../../core/services/notifications_service.dart';
import '../../core/utils/dates.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<DateTime> examDate() => _db.examDate();

  Stream<DateTime> watchExamDate() {
    return (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals('examDate'))).watchSingleOrNull().map(
      (row) => row == null ? strToDate(defaultExamDate) : strToDate(row.value),
    );
  }

  Future<void> setExamDate(DateTime date) =>
      _db.setSetting('examDate', dateToStr(date));

  Future<(int focus, int breakMin)> focusDurations() async {
    final focus =
        int.tryParse(await _db.getSetting('focusMinutes') ?? '') ?? 50;
    final brk = int.tryParse(await _db.getSetting('breakMinutes') ?? '') ?? 10;
    return (focus, brk);
  }

  Stream<(int, int)> watchFocusDurations() {
    return _db.select(_db.appSettings).watch().map((rows) {
      final byKey = {for (final r in rows) r.key: r.value};
      return (
        int.tryParse(byKey['focusMinutes'] ?? '') ?? 50,
        int.tryParse(byKey['breakMinutes'] ?? '') ?? 10,
      );
    });
  }

  Future<void> setFocusDurations(int focus, int brk) async {
    await _db.setSetting('focusMinutes', '$focus');
    await _db.setSetting('breakMinutes', '$brk');
  }

  Future<(bool enabled, int minutes)> waterReminder() async {
    final enabled =
        (await _db.getSetting('waterReminderEnabled') ?? '1') == '1';
    final minutes =
        int.tryParse(await _db.getSetting('waterReminderMinutes') ?? '') ?? 30;
    return (enabled, minutes);
  }

  Stream<({bool enabled, int minutes})> watchWaterReminder() {
    return _db.select(_db.appSettings).watch().map((rows) {
      final byKey = {for (final r in rows) r.key: r.value};
      return (
        enabled: (byKey['waterReminderEnabled'] ?? '1') == '1',
        minutes: int.tryParse(byKey['waterReminderMinutes'] ?? '') ?? 30,
      );
    });
  }

  Future<void> setWaterReminder(bool enabled, int minutes) async {
    await _db.setSetting('waterReminderEnabled', enabled ? '1' : '0');
    await _db.setSetting('waterReminderMinutes', '$minutes');
  }

  Stream<({bool enabled, int minutes})> watchStretchReminder() {
    return _db.select(_db.appSettings).watch().map((rows) {
      final byKey = {for (final r in rows) r.key: r.value};
      return (
        enabled: (byKey['stretchReminderEnabled'] ?? '1') == '1',
        minutes: int.tryParse(byKey['stretchReminderMinutes'] ?? '') ?? 25,
      );
    });
  }

  Future<void> setStretchReminder(bool enabled, int minutes) async {
    await _db.setSetting('stretchReminderEnabled', enabled ? '1' : '0');
    await _db.setSetting('stretchReminderMinutes', '$minutes');
  }

  Stream<NotificationPrefs> watchNotificationPrefs() {
    return _db.select(_db.appSettings).watch().map((rows) {
      final byKey = {for (final r in rows) r.key: r.value};
      return (
        study: (byKey['studyRemindersEnabled'] ?? '1') == '1',
        rest: (byKey['restRemindersEnabled'] ?? '1') == '1',
        revision: (byKey['revisionRemindersEnabled'] ?? '1') == '1',
        sleep: (byKey['sleepReminderEnabled'] ?? '1') == '1',
        morning: (byKey['morningReminderEnabled'] ?? '1') == '1',
      );
    });
  }

  Future<void> setNotificationPrefs({
    bool? study,
    bool? rest,
    bool? revision,
    bool? sleep,
    bool? morning,
  }) async {
    if (study != null) {
      await _db.setSetting('studyRemindersEnabled', study ? '1' : '0');
    }
    if (rest != null) {
      await _db.setSetting('restRemindersEnabled', rest ? '1' : '0');
    }
    if (revision != null) {
      await _db.setSetting('revisionRemindersEnabled', revision ? '1' : '0');
    }
    if (sleep != null) {
      await _db.setSetting('sleepReminderEnabled', sleep ? '1' : '0');
    }
    if (morning != null) {
      await _db.setSetting('morningReminderEnabled', morning ? '1' : '0');
    }
  }

  Future<String> preset() async {
    return await _db.getSetting('focusPreset') ?? '50/10';
  }

  Future<void> setPreset(String preset) =>
      _db.setSetting('focusPreset', preset);

  /// Watches a single settings value by key (null when unset).
  Stream<String?> watchSetting(String key) {
    return (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<void> setSetting(String key, String value) =>
      _db.setSetting(key, value);

  /// "Bad day mode" is scoped to a single day so it auto-expires on the next
  /// day's first write/tick.
  String badDayKey(DateTime day) => 'badDayMode:${dateToStr(day)}';

  Future<bool> badDay(DateTime day) async {
    return (await _db.getSetting(badDayKey(day))) == '1';
  }

  Future<void> setBadDay(DateTime day, bool on) =>
      _db.setSetting(badDayKey(day), on ? '1' : '0');
}
