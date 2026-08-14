import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/dates.dart';
import 'providers.dart';

/// An in-app reminder shown only while the app is in the foreground. The OS
/// notification for the same moment still covers the background case.
class ForegroundReminder {
  const ForegroundReminder({
    required this.kind,
    required this.id,
    required this.title,
    required this.body,
  });

  final String kind;
  final String id;
  final String title;
  final String body;
}

/// Watches the day's timetable while the app is in the foreground and fires a
/// rest reminder when a study slot ends, so the student is prompted inside the
/// app instead of only getting an OS notification.
class ForegroundReminderController extends Notifier<ForegroundReminder?> {
  ForegroundReminderController({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  Timer? _timer;
  final Set<String> _shown = {};
  String _dayKey = '';

  @override
  ForegroundReminder? build() {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _check());
    _check();
    return null;
  }

  Future<void> _check() async {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final now = _now();
    final day = dateToStr(now);
    if (day != _dayKey) {
      _shown.clear();
      _dayKey = day;
    }

    final nowMin = now.hour * 60 + now.minute;
    final slots = await ref.read(daySlotsProvider(now).future);
    for (final slot in slots) {
      if (!slot.activityType.isStudyLike) continue;
      final end = slot.endMin;
      final endedJustNow = end <= nowMin && nowMin - end < 1;
      if (!endedJustNow) continue;
      final key = 'rest-$day-${slot.id}';
      if (_shown.contains(key)) continue;
      _shown.add(key);
      state = ForegroundReminder(
        kind: 'rest',
        id: key,
        title: 'Time to rest',
        body: '${slot.title} is done. Stand up, stretch, and drink some water.',
      );
      return;
    }
  }

  /// Called once the UI has shown (or the user dismissed) the reminder.
  void dismissed() => state = null;
}

final foregroundReminderProvider =
    NotifierProvider<ForegroundReminderController, ForegroundReminder?>(
      ForegroundReminderController.new,
    );
