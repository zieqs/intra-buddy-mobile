import 'package:audioplayers/audioplayers.dart';

/// Owns the single short chime used by the celebration overlay.
///
/// One player is prepared once at startup so the first ding is not delayed by
/// decoding. Playback failures are swallowed: audio is never critical.
class CelebrationAudio {
  CelebrationAudio._();

  static final CelebrationAudio instance = CelebrationAudio._();

  final AudioPlayer _player = AudioPlayer();
  bool _prepared = false;
  bool _unavailable = false;

  Future<void> prepare() async {
    if (_prepared || _unavailable) return;

    try {
      await _player.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
          respectSilence: true,
        ).build(),
      );
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(0.7);
      await _player.setSource(AssetSource('audio/celebration.wav'));
      _prepared = true;
    } catch (_) {
      _unavailable = true;
    }
  }

  Future<void> play() async {
    await prepare();
    if (!_prepared) return;

    try {
      await _player.stop();
      await _player.resume();
    } catch (_) {
      _unavailable = true;
    }
  }
}
