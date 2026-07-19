import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
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
    );
  }
}

class NotificationService extends ChangeNotifier {
  static const String _boxName = 'notifications_box';
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
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
  }) async {
    if (_box == null) await init();
    final notification = AppNotification(
      id: const Uuid().v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
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
