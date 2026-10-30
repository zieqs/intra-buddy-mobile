import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/celebration_feedback.dart';

void main() {
  test('plays the chime and gives a haptic when enabled', () async {
    var plays = 0;
    var haptics = 0;
    final feedback = CelebrationFeedback(
      playSound: () async => plays++,
      haptic: () async => haptics++,
    );

    await feedback.celebrate(soundEnabled: true);

    expect(plays, 1);
    expect(haptics, 1);
  });

  test('stays silent but still gives a haptic when disabled', () async {
    var plays = 0;
    var haptics = 0;
    final feedback = CelebrationFeedback(
      playSound: () async => plays++,
      haptic: () async => haptics++,
    );

    await feedback.celebrate(soundEnabled: false);

    expect(plays, 0);
    expect(haptics, 1);
  });

  test('a broken player never breaks the celebration', () async {
    var attempts = 0;
    final feedback = CelebrationFeedback(
      playSound: () async {
        attempts++;
        throw StateError('no audio device');
      },
      haptic: () async => throw StateError('no vibrator'),
    );

    await expectLater(
      feedback.celebrate(soundEnabled: true),
      completes,
    );
    expect(attempts, 1);
  });
}
