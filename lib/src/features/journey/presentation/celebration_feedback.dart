import 'package:flutter/services.dart';

import '../../../core/utils/app_logger.dart';

/// The small reward that lands with the celebration overlay.
///
/// The app wires this through `celebration_providers.dart`; the sound is
/// skipped when the student has turned celebration sounds off, but the haptic
/// still confirms the completion.
class CelebrationFeedback {
  CelebrationFeedback({
    required Future<void> Function() playSound,
    Future<void> Function()? haptic,
  }) : _playSound = playSound,
       _haptic = haptic ?? HapticFeedback.mediumImpact;

  final Future<void> Function() _playSound;
  final Future<void> Function() _haptic;

  Future<void> celebrate({required bool soundEnabled}) async {
    try {
      await _haptic();
    } catch (error, stackTrace) {
      // Haptics are a bonus; never let them block the celebration.
      AppLogger.warning(
        'Haptic feedback failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (!soundEnabled) return;

    try {
      await _playSound();
    } catch (error, stackTrace) {
      // A missing audio device must not break marking a milestone.
      AppLogger.warning(
        'Celebration sound failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
