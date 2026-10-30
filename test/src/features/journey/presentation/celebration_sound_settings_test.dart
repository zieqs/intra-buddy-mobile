import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/celebration_sound_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('celebration sounds are on by default', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(celebrationSoundEnabledProvider.future), isTrue);
  });

  test('reads a stored preference', () async {
    SharedPreferences.setMockInitialValues({
      'celebration_sound_enabled': false,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(celebrationSoundEnabledProvider.future),
      isFalse,
    );
  });

  test('persists a change', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(celebrationSoundEnabledProvider.future);

    await container
        .read(celebrationSoundEnabledProvider.notifier)
        .setEnabled(false);

    expect(container.read(celebrationSoundEnabledProvider).value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('celebration_sound_enabled'), isFalse);
  });
}
