import '../../core/db/database.dart';
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

  Future<String> preset() async {
    return await _db.getSetting('focusPreset') ?? '50/10';
  }

  Future<void> setPreset(String preset) =>
      _db.setSetting('focusPreset', preset);
}
