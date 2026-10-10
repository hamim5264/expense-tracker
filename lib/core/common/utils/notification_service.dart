import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/services/firebase_notification_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String? linkUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.linkUrl,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? linkUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      linkUrl: linkUrl ?? this.linkUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'linkUrl': linkUrl,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'info',
      linkUrl: json['linkUrl'] as String?,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static const String _boxName = 'notifications_box';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Box? _box;
  bool _isNotificationsEnabled = true;

  bool get isNotificationsEnabled => _isNotificationsEnabled;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    await sanitizeDuplicates();
    await _loadPreferences();

    // Check actual OS permission status
    try {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        _isNotificationsEnabled = false;
        notifyListeners();
      }
    } catch (_) {}

    if (_isNotificationsEnabled) {
      await FirebaseNotificationService.instance.subscribeToAnnouncements();
      fetchRemoteAnnouncements();
    } else {
      await FirebaseNotificationService.instance.unsubscribeFromAnnouncements();
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      try {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final requested = await Permission.notification.request();
          if (!requested.isGranted) {
            if (requested.isPermanentlyDenied) {
              await openAppSettings();
            }
            _isNotificationsEnabled = false;
            notifyListeners();
            return false;
          }
        }
      } catch (e) {
        debugPrint('Error checking notification permission: $e');
      }
    }

    _isNotificationsEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotificationsEnabled, enabled);
    } catch (_) {}
    if (enabled) {
      await FirebaseNotificationService.instance.subscribeToAnnouncements();
      fetchRemoteAnnouncements();
    } else {
      await FirebaseNotificationService.instance.unsubscribeFromAnnouncements();
    }
    return true;
  }

  Future<void> fetchRemoteAnnouncements() async {
    if (_box == null) await init();
    if (!_isNotificationsEnabled) return;
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('system_announcements')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      bool addedAny = false;
      for (final row in response) {
        final title = row['title'] as String? ?? '';
        final message = row['message'] as String? ?? '';
        final type = row['type'] as String? ?? 'info';
        final linkUrl = row['link_url'] as String?;
        final createdAtStr = row['created_at'] as String?;
        final timestamp =
            createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();

        if (title.isEmpty || message.isEmpty) continue;

        final isDuplicate = notifications.any(
          (n) => n.title == title && n.message == message,
        );

        if (!isDuplicate) {
          final id = row['id']?.toString() ?? const Uuid().v4();
          final notification = AppNotification(
            id: id,
            title: title,
            message: message,
            timestamp: timestamp,
            type: type,
            isRead: false,
            linkUrl: linkUrl,
          );
          await _box!.put(notification.id, notification.toJson());
          addedAny = true;
        }
      }
      if (addedAny) {
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> sanitizeDuplicates() async {
    if (_box == null) return;
    final seenKeys = <String>{};
    final keysToRemove = <dynamic>[];

    for (final key in _box!.keys) {
      final raw = _box!.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        final notification = AppNotification.fromJson(map);
        final uniqueKey = '${notification.title}_${notification.message}';
        if (seenKeys.contains(uniqueKey)) {
          keysToRemove.add(key);
        } else {
          seenKeys.add(uniqueKey);
        }
      }
    }

    if (keysToRemove.isNotEmpty) {
      await _box!.deleteAll(keysToRemove);
      notifyListeners();
    }
  }

  List<AppNotification> get notifications {
    if (_box == null) return [];
    final rawList = _box!.values.toList();
    final list = rawList.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return AppNotification.fromJson(map);
    }).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int get unreadCount {
    if (_box == null) return 0;
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String? linkUrl,
  }) async {
    if (_box == null) await init();

    final isDuplicate = notifications.any(
      (n) => n.title == title && n.message == message,
    );
    if (isDuplicate) return;

    final notification = AppNotification(
      id: const Uuid().v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      linkUrl: linkUrl,
    );
    await _box!.put(notification.id, notification.toJson());
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    if (_box == null) return;
    final raw = _box!.get(id);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw as Map);
      final notification = AppNotification.fromJson(map);
      final updated = notification.copyWith(isRead: true);
      await _box!.put(id, updated.toJson());
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_box == null) return;
    for (final key in _box!.keys) {
      final raw = _box!.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        final notification = AppNotification.fromJson(map);
        if (!notification.isRead) {
          final updated = notification.copyWith(isRead: true);
          await _box!.put(key, updated.toJson());
        }
      }
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    if (_box == null) return;
    await _box!.clear();
    notifyListeners();
  }
}
