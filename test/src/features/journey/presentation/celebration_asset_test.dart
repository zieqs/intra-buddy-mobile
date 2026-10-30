import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ships the celebration chime', () async {
    final data = await rootBundle.load('assets/audio/celebration.wav');

    expect(data.lengthInBytes, greaterThan(20000));
  });

  test('the chime actually contains audio', () async {
    final data = await rootBundle.load('assets/audio/celebration.wav');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // A 44-byte PCM header followed by all-zero samples would be an audible
    // no-op: the celebration would be silent even though the asset exists.
    expect(bytes.skip(44).any((byte) => byte != 0), isTrue);
  });
}
