import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../../app/navigation_keys.dart';
import '../../../../app/startup_intent.dart';
import '../logbook_reminder_planner.dart';

/// Schedules local logbook reminders on the device.
///
/// These fire even when the app is closed; no server or Firebase involved.
class LogbookReminderService {
  LogbookReminderService._();

  static final LogbookReminderService instance = LogbookReminderService._();

  static const int _baseNotificationId = 5000;
  static const int _maxWeeks = 30;
  static const int _testNotificationId = 5999;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'logbook_reminders',
      'Logbook reminders',
      channelDescription:
          'Reminders to submit your weekly logbook before the deadline',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Fall back to the package default if the platform zone is unavailable.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;

    // A tap on a reminder while the app was fully terminated never reaches the
    // callback above; the launch payload is only available here.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true &&
        launch?.notificationResponse?.payload == 'logbook') {
      StartupIntent.openLogbook = true;
    }
  }

  /// Replaces all pending reminders with a fresh plan.
  Future<void> reschedule(List<ReminderWeek> weeks) async {
    try {
      await init();
      await _requestPermissions();

      for (
        var id = _baseNotificationId + 1;
        id <= _baseNotificationId + _maxWeeks;
        id++
      ) {
        await _plugin.cancel(id: id);
      }

      final plan = planLogbookReminders(weeks: weeks, now: DateTime.now());
      for (final reminder in plan) {
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime.from(reminder.scheduledAt, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'logbook',
        );
      }
    } catch (_) {
      // Reminders are best-effort; never break the screen that triggered them.
    }
  }

  /// Shows a notification immediately. Used by the debug-only Settings action
  /// to verify that permissions and the system channel work.
  Future<bool> showTestNotification() async {
    try {
      await init();
      await _requestPermissions();
      await _plugin.show(
        id: _testNotificationId,
        title: 'Logbook reminder test',
        body: 'If you can see this, system notifications are working.',
        notificationDetails: _details,
        payload: 'logbook',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != 'logbook') return;
    final context = appRootNavigatorKey.currentContext;
    if (context == null) return;
    GoRouter.of(context).push('/logbook');
  }
}
