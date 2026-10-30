import 'package:flutter/services.dart';

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
    } catch (_) {
      // Haptics are a bonus; never let them block the celebration.
    }

    if (!soundEnabled) return;

    try {
      await _playSound();
    } catch (_) {
      // A missing audio device must not break marking a milestone.
    }
  }
}
