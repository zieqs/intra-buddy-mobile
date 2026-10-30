import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'celebration_feedback.dart';
import 'services/celebration_audio.dart';

final celebrationAudioProvider = Provider<CelebrationAudio>(
  (ref) => CelebrationAudio.instance,
);

final celebrationFeedbackProvider = Provider<CelebrationFeedback>((ref) {
  final audio = ref.watch(celebrationAudioProvider);
  return CelebrationFeedback(playSound: audio.play);
});
