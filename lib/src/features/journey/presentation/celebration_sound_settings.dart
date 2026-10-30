import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const celebrationSoundKey = 'celebration_sound_enabled';

/// On by default. The value is stored on the device so the choice survives
/// restarts without needing a backend round-trip.
final celebrationSoundEnabledProvider =
    AsyncNotifierProvider<CelebrationSoundSetting, bool>(
      CelebrationSoundSetting.new,
    );

class CelebrationSoundSetting extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(celebrationSoundKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = AsyncData(enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(celebrationSoundKey, enabled);
  }
}
