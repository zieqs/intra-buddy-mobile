import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/notification_time.dart';

void main() {
  final now = DateTime(2026, 10, 30, 12);

  test('shows just now for under a minute', () {
    expect(
      timeAgo(now.subtract(const Duration(seconds: 30)), now: now),
      'Just now',
    );
  });

  test('shows minutes', () {
    expect(
      timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
      '5m ago',
    );
  });

  test('shows hours', () {
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now: now), '3h ago');
  });

  test('shows days within a week', () {
    expect(timeAgo(now.subtract(const Duration(days: 2)), now: now), '2d ago');
  });

  test('shows a date after a week', () {
    expect(timeAgo(DateTime(2026, 10, 20), now: now), '20 Oct');
  });
}
