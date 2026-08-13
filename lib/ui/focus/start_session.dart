import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../state/focus_controller.dart';
import 'focus_screen.dart';

class StartSession {
  /// Pushes the immersive focus screen for [slot], starting the timer.
  static Future<void> begin(
    BuildContext context,
    FocusController controller,
    TimetableSlot slot,
    String subjectName,
    int focusMinutes,
    int breakMinutes,
  ) async {
    controller.startFocus(
      slotId: slot.id,
      subjectId: slot.subjectId,
      subjectName: subjectName,
      title: slot.title,
      target: slot.target,
      focusMinutes: focusMinutes,
      breakMinutes: breakMinutes,
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FocusScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
