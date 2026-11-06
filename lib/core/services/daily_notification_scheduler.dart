import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyNotificationScheduler {
  static const int morningNotificationId = 1001;
  static const int nightNotificationId = 1002;
  static const int budgetAlertNotificationId = 2001;
  static const int testNotificationId = 9999;

  static const String keyMorningEnabled = 'morning_reminder_enabled';
  static const String keyNightEnabled = 'night_reminder_enabled';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static const AndroidNotificationChannel _reminderChannel =
      AndroidNotificationChannel(
    'onyx_daily_reminders',
    'Daily Reminders & Alerts',
    description: 'Daily morning plans, night expense reminders, and budget alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidInit =
          AndroidInitializationSettings('@drawable/ic_notification');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_reminderChannel);

      _isInitialized = true;
      debugPrint('🔔 DailyNotificationScheduler initialized.');

      // Reschedule according to user preferences
      await syncSchedules();
    } catch (e) {
      debugPrint('⚠️ Error initializing DailyNotificationScheduler: $e');
    }
  }

  static Future<bool> isMorningEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyMorningEnabled) ?? true;
  }

  static Future<bool> isNightEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNightEnabled) ?? true;
  }

  static Future<void> setMorningEnabled(bool enabled, {String userName = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyMorningEnabled, enabled);
    if (enabled) {
      await scheduleMorningNotification(userName: userName);
    } else {
      await _localNotifications.cancel(morningNotificationId);
      debugPrint('🛑 Morning notification cancelled.');
    }
  }

  static Future<void> setNightEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNightEnabled, enabled);
    if (enabled) {
      await scheduleNightNotification();
    } else {
      await _localNotifications.cancel(nightNotificationId);
      debugPrint('🛑 Night notification cancelled.');
    }
  }

  static Future<void> syncSchedules({String userName = ''}) async {
    final morning = await isMorningEnabled();
    final night = await isNightEnabled();

    if (morning) {
      await scheduleMorningNotification(userName: userName);
    } else {
      await _localNotifications.cancel(morningNotificationId);
    }

    if (night) {
      await scheduleNightNotification();
    } else {
      await _localNotifications.cancel(nightNotificationId);
    }
  }

  static Future<void> scheduleMorningNotification({String userName = ''}) async {
    try {
      final greetingTarget = userName.trim().isNotEmpty ? ' $userName' : '';
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        8, // 8:00 AM
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        morningNotificationId,
        'Good Morning$greetingTarget! ☀️',
        "Let's start today's expense or income plan with onyx",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'onyx_daily_reminders',
            'Daily Reminders & Alerts',
            channelDescription:
                'Daily morning plans, night expense reminders, and budget alerts',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            color: Color(0xFF4F378A),
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'morning_routine',
      );

      debugPrint('✅ Morning notification scheduled for 8:00 AM daily.');
    } catch (e) {
      debugPrint('⚠️ Error scheduling morning notification: $e');
    }
  }

  static Future<void> scheduleNightNotification() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        21, // 9:00 PM
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        nightNotificationId,
        'Onyx Daily Reminder 🌙',
        "Forget to add expenses or income? no worries onyx reminder is here for you, let's add today's expenses",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'onyx_daily_reminders',
            'Daily Reminders & Alerts',
            channelDescription:
                'Daily morning plans, night expense reminders, and budget alerts',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            color: Color(0xFF4F378A),
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'night_reminder',
      );

      debugPrint('✅ Night notification scheduled for 9:00 PM daily.');
    } catch (e) {
      debugPrint('⚠️ Error scheduling night notification: $e');
    }
  }

  /// Sends an immediate test notification to the running device.
  static Future<void> sendImmediateTestNotification({
    String title = 'Onyx Push Notification Test 🚀',
    String body = 'Test notification delivered successfully to your device!',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'onyx_daily_reminders',
        'Daily Reminders & Alerts',
        channelDescription:
            'Daily morning plans, night expense reminders, and budget alerts',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        color: Color(0xFF4F378A),
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      testNotificationId,
      title,
      body,
      details,
      payload: 'test_notification',
    );
    debugPrint('🔔 Test notification sent to running device.');
  }

  /// Triggered when an active budget goal is exceeded or approaching limit.
  static Future<void> triggerBudgetAlert({
    required String budgetName,
    required double spent,
    required double target,
    required String currency,
  }) async {
    if (!_isInitialized) await initialize();

    final isExceeded = spent > target;
    final title = isExceeded
        ? 'Budget Exceeded: $budgetName ⚠️'
        : 'Budget Warning: $budgetName ⚠️';
    final body = isExceeded
        ? "You've exceeded your $budgetName budget ($currency ${spent.toStringAsFixed(0)} / ${target.toStringAsFixed(0)})."
        : "You have reached 90% of your $budgetName budget.";

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'onyx_daily_reminders',
        'Daily Reminders & Alerts',
        channelDescription: 'Daily morning plans, night expense reminders, and budget alerts',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        color: Color(0xFFEF4444),
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      budgetName.hashCode,
      title,
      body,
      details,
      payload: 'budget_alert',
    );
  }

  /// Triggered when a loan due date is today or overdue.
  static Future<void> triggerLoanDueAlert({
    required String personName,
    required double amount,
    required String currency,
    bool isOverdue = false,
  }) async {
    if (!_isInitialized) await initialize();

    final title = isOverdue
        ? 'Overdue Loan Alert: $personName ⏰'
        : 'Loan Due Today: $personName 📅';
    final body =
        'Loan of $currency ${amount.toStringAsFixed(0)} with $personName is ${isOverdue ? 'overdue' : 'due today'}.';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'onyx_daily_reminders',
        'Daily Reminders & Alerts',
        channelDescription: 'Daily morning plans, night expense reminders, and budget alerts',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        color: Color(0xFFF59E0B),
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      personName.hashCode,
      title,
      body,
      details,
      payload: 'loan_alert',
    );
  }
}

