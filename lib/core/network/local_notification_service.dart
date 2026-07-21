import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  LocalNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LocalNotificationItem.fromJson(Map<String, dynamic> json) =>
      LocalNotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class LocalNotificationService {
  static const String _key = 'local_notifications';
  static final StreamController<void> _onNotificationAdded =
      StreamController<void>.broadcast();

  static Stream<void> get onNotificationAdded => _onNotificationAdded.stream;

  static Future<List<LocalNotificationItem>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key);
      if (list == null) return [];
      return list
          .map((item) => LocalNotificationItem.fromJson(
              jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotification(String title, String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();
      // Avoid duplicate notifications with same title and body within 1 minute
      final now = DateTime.now();
      final exists = notifications.any((n) =>
          n.title == title &&
          n.body == body &&
          now.difference(n.timestamp).inMinutes < 1);
      if (exists) return;

      final newItem = LocalNotificationItem(
        id: now.microsecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: now,
      );
      notifications.insert(0, newItem);
      // Keep only last 50 notifications
      if (notifications.length > 50) {
        notifications.removeRange(50, notifications.length);
      }
      final list = notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_key, list);
      _onNotificationAdded.add(null);
    } catch (_) {}
  }

  static Future<void> deleteNotification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == id);
      final list = notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_key, list);
      _onNotificationAdded.add(null);
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      _onNotificationAdded.add(null);
    } catch (_) {}
  }
}
