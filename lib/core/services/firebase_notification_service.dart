import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('FCM background message: ${message.messageId}');
  } catch (e) {
    log('FCM background message error: $e');
  }
}

class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance = FirebaseNotificationService._();

  bool _initialized = false;
  FirebaseMessaging? _messaging;
  String? _fcmToken;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Onyx Announcements',
    description: 'Important announcements and notifications',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  String? get fcmToken => _fcmToken;

  FirebaseMessaging get messaging {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  String? _extractUrl(RemoteMessage message) {
    final data = message.data;
    final candidates = [
      data['url'],
      data['link'],
      data['link_url'],
      data['playstore_url'],
      data['play_store'],
      data['playstore'],
      data['store_url'],
      data['market_url'],
      data['app_url'],
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.toString().trim().isNotEmpty) {
        return candidate.toString().trim();
      }
    }
    return null;
  }

  Future<void> launchNotificationUrl(String? rawUrl) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) return;
    try {
      final uri = Uri.parse(rawUrl.trim());
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (_) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('⚠️ Error launching notification url: $e');
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Setup Local Notifications (for Foreground heads-up notifications)
      const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Local notification clicked: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            launchNotificationUrl(response.payload);
          }
        },
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);

      // 3. Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Set foreground presentation options
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Request native OS permission (Android 13+ & iOS)
      try {
        final status = await Permission.notification.request();
        debugPrint('🔔 Native OS Notification Permission Status: $status');
      } catch (e) {
        debugPrint('⚠️ Error requesting native notification permission: $e');
      }

      // 6. Request FCM permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('🔔 FCM Notification Permission Status: ${settings.authorizationStatus}');

      // 7. Setup foreground listener (shows heads-up notification in status bar!)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('════════════════════════════════════════════════════════════');
        debugPrint('🔔 [FCM FOREGROUND MESSAGE RECEIVED]:');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
        debugPrint('════════════════════════════════════════════════════════════');

        final title = message.notification?.title ?? message.data['title'] ?? 'Onyx';
        final body = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';
        final linkUrl = _extractUrl(message);

        if (title.isNotEmpty || body.isNotEmpty) {
          // Display heads-up banner in the phone's notification bar
          _localNotifications.show(
            message.hashCode,
            title,
            body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Onyx Announcements',
                channelDescription: 'Important announcements and notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@drawable/ic_notification',
                color: Color(0xFF4F378A),
                playSound: true,
                enableVibration: true,
              ),
            ),
            payload: linkUrl,
          );

          // Save into in-app notification box
          NotificationService().addNotification(
            title: title.isNotEmpty ? title : 'Announcement',
            message: body,
            type: message.data['type'] ?? 'info',
            linkUrl: linkUrl,
          );
        }
      });

      // 8. Setup Notification click handlers (background tap)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM opened from background: ${message.data}');
        final url = _extractUrl(message);
        if (url != null) {
          launchNotificationUrl(url);
        }
      });

      // 9. Setup Notification click handler (terminated state tap)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM opened from terminated state: ${initialMessage.data}');
        final url = _extractUrl(initialMessage);
        if (url != null) {
          Future.delayed(const Duration(milliseconds: 600), () {
            launchNotificationUrl(url);
          });
        }
      }

      // 7. Subscribe to announcement topics by default
      await subscribeToAnnouncements();

      try {
        final token = await messaging.getToken();
        _fcmToken = token;
        debugPrint('════════════════════════════════════════════════════════════');
        debugPrint('🔥 FCM DEVICE TOKEN:');
        debugPrint('$token');
        debugPrint('════════════════════════════════════════════════════════════');
        log('FCM Device Token: $token');
      } catch (e) {
        debugPrint('⚠️ Error fetching FCM device token: $e');
      }

      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔥 FCM TOKEN REFRESHED: $newToken');
      });

      _initialized = true;
    } catch (e, stack) {
      log('Error initializing FirebaseNotificationService: $e', stackTrace: stack);
    }
  }

  Future<String?> printToken() async {
    try {
      final token = await messaging.getToken();
      _fcmToken = token;
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('🔥 FCM DEVICE TOKEN:');
      debugPrint('$token');
      debugPrint('════════════════════════════════════════════════════════════');
      return token;
    } catch (e) {
      debugPrint('⚠️ Error fetching FCM device token: $e');
      return null;
    }
  }

  Future<void> subscribeToAnnouncements() async {
    try {
      await messaging.subscribeToTopic('announcements');
      await messaging.subscribeToTopic('all_users');
      log('Subscribed to announcements & all_users');
    } catch (e) {
      log('Error subscribing to topics: $e');
    }
  }

  Future<void> unsubscribeFromAnnouncements() async {
    try {
      await messaging.unsubscribeFromTopic('announcements');
      await messaging.unsubscribeFromTopic('all_users');
      log('Unsubscribed from announcements & all_users');
    } catch (e) {
      log('Error unsubscribing from topics: $e');
    }
  }
}
