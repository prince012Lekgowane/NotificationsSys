import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../models/device_model.dart';
import '../models/topic_model.dart';
import '../../core/constants/constants.dart';

abstract class LocalDataSource {
  Future<void> saveDevice(DeviceModel device);
  Future<DeviceModel?> getDevice(String deviceId);
  Future<List<DeviceModel>> getAllDevices();
  Future<void> removeDevice(String deviceId);

  Future<void> saveNotification(NotificationModel notification);
  Future<List<NotificationModel>> getNotificationHistory({int limit = 50});
  Future<NotificationModel?> getNotification(String notificationId);
  Future<void> removeNotification(String notificationId);
  Future<void> clearNotificationHistory();

  Future<void> saveTopics(List<TopicModel> topics);
  Future<List<TopicModel>> getTopics();
  Future<void> addTopic(TopicModel topic);
  Future<void> removeTopic(String topicId);

  Future<void> saveSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>> getSettings();

  Future<void> showLocalNotification(NotificationModel notification);
  Future<void> cancelLocalNotification(int id);
  Future<void> cancelAllLocalNotifications();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  LocalDataSourceImpl(
      this.sharedPreferences, this.flutterLocalNotificationsPlugin);

  @override
  Future<void> saveDevice(DeviceModel device) async {
    try {
      final deviceJson = json.encode(device.toJson());
      await sharedPreferences.setString('device_${device.id}', deviceJson);

      // Update devices list
      final deviceIds = sharedPreferences.getStringList('device_ids') ?? [];
      if (!deviceIds.contains(device.id)) {
        deviceIds.add(device.id);
        await sharedPreferences.setStringList('device_ids', deviceIds);
      }
    } catch (e) {
      throw Exception('Failed to save device: $e');
    }
  }

  @override
  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final deviceJson = sharedPreferences.getString('device_$deviceId');
      if (deviceJson == null) return null;

      final deviceMap = json.decode(deviceJson) as Map<String, dynamic>;
      return DeviceModel.fromJson(deviceMap);
    } catch (e) {
      throw Exception('Failed to get device: $e');
    }
  }

  @override
  Future<List<DeviceModel>> getAllDevices() async {
    try {
      final deviceIds = sharedPreferences.getStringList('device_ids') ?? [];
      final devices = <DeviceModel>[];

      for (final deviceId in deviceIds) {
        final device = await getDevice(deviceId);
        if (device != null) {
          devices.add(device);
        }
      }

      return devices;
    } catch (e) {
      throw Exception('Failed to get all devices: $e');
    }
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    try {
      await sharedPreferences.remove('device_$deviceId');

      final deviceIds = sharedPreferences.getStringList('device_ids') ?? [];
      deviceIds.remove(deviceId);
      await sharedPreferences.setStringList('device_ids', deviceIds);
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final notificationJson = json.encode(notification.toJson());
      await sharedPreferences.setString(
          'notification_${notification.id}', notificationJson);

      // Update notifications list
      final notificationIds =
          sharedPreferences.getStringList('notification_ids') ?? [];
      if (!notificationIds.contains(notification.id)) {
        notificationIds.add(notification.id);

        // Keep only the latest notifications (limit to maxNotificationHistory)
        if (notificationIds.length >
            NotificationConstants.maxNotificationHistory) {
          final oldNotificationId = notificationIds.removeAt(0);
          await sharedPreferences.remove('notification_$oldNotificationId');
        }

        await sharedPreferences.setStringList(
            'notification_ids', notificationIds);
      }
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationHistory(
      {int limit = 50}) async {
    try {
      final notificationIds =
          sharedPreferences.getStringList('notification_ids') ?? [];
      final notifications = <NotificationModel>[];

      // Get the most recent notifications (reverse order)
      final recentIds = notificationIds.reversed.take(limit);

      for (final notificationId in recentIds) {
        final notification = await getNotification(notificationId);
        if (notification != null) {
          notifications.add(notification);
        }
      }

      return notifications;
    } catch (e) {
      throw Exception('Failed to get notification history: $e');
    }
  }

  @override
  Future<NotificationModel?> getNotification(String notificationId) async {
    try {
      final notificationJson =
          sharedPreferences.getString('notification_$notificationId');
      if (notificationJson == null) return null;

      final notificationMap =
          json.decode(notificationJson) as Map<String, dynamic>;
      return NotificationModel.fromJson(notificationMap);
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  @override
  Future<void> removeNotification(String notificationId) async {
    try {
      await sharedPreferences.remove('notification_$notificationId');

      final notificationIds =
          sharedPreferences.getStringList('notification_ids') ?? [];
      notificationIds.remove(notificationId);
      await sharedPreferences.setStringList(
          'notification_ids', notificationIds);
    } catch (e) {
      throw Exception('Failed to remove notification: $e');
    }
  }

  @override
  Future<void> clearNotificationHistory() async {
    try {
      final notificationIds =
          sharedPreferences.getStringList('notification_ids') ?? [];

      for (final notificationId in notificationIds) {
        await sharedPreferences.remove('notification_$notificationId');
      }

      await sharedPreferences.remove('notification_ids');
    } catch (e) {
      throw Exception('Failed to clear notification history: $e');
    }
  }

  @override
  Future<void> saveTopics(List<TopicModel> topics) async {
    try {
      final topicsJson = topics.map((topic) => topic.toJson()).toList();
      final topicsJsonString = json.encode(topicsJson);
      await sharedPreferences.setString('topics', topicsJsonString);
    } catch (e) {
      throw Exception('Failed to save topics: $e');
    }
  }

  @override
  Future<List<TopicModel>> getTopics() async {
    try {
      final topicsJsonString = sharedPreferences.getString('topics');
      if (topicsJsonString == null) return [];

      final topicsJson = json.decode(topicsJsonString) as List<dynamic>;
      return topicsJson
          .map((topicJson) =>
              TopicModel.fromJson(topicJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get topics: $e');
    }
  }

  @override
  Future<void> addTopic(TopicModel topic) async {
    try {
      final topics = await getTopics();
      topics.add(topic);
      await saveTopics(topics);
    } catch (e) {
      throw Exception('Failed to add topic: $e');
    }
  }

  @override
  Future<void> removeTopic(String topicId) async {
    try {
      final topics = await getTopics();
      topics.removeWhere((topic) => topic.id == topicId);
      await saveTopics(topics);
    } catch (e) {
      throw Exception('Failed to remove topic: $e');
    }
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final settingsJson = json.encode(settings);
      await sharedPreferences.setString(
          NotificationConstants.notificationSettingsKey, settingsJson);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final settingsJson = sharedPreferences
          .getString(NotificationConstants.notificationSettingsKey);
      if (settingsJson == null) {
        // Return default settings
        return {
          'enabled': true,
          'sound': true,
          'vibration': true,
          'badge': true,
          'types': {
            NotificationConstants.typeGeneral: true,
            NotificationConstants.typePromotion: true,
            NotificationConstants.typeAlert: true,
            NotificationConstants.typeMessage: true,
          },
          'quietHours': {
            'enabled': false,
            'startHour': 22,
            'endHour': 7,
          },
        };
      }

      return json.decode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  @override
  Future<void> showLocalNotification(NotificationModel notification) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _getChannelId(notification.type),
        _getChannelName(notification.type),
        channelDescription: _getChannelDescription(notification.type),
        importance: _getImportance(notification.priority),
        priority: _getPriority(notification.priority),
        icon: notification.iconUrl,
        color: notification.color != null
            ? Color((int.parse(notification.color!.replaceFirst('#', ''),
                    radix: 16)) |
                0xFF000000)
            : null,
        tag: notification.tag,
        groupKey: notification.group,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: json.encode(notification.data),
      );
    } catch (e) {
      throw Exception('Failed to show local notification: $e');
    }
  }

  @override
  Future<void> cancelLocalNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      throw Exception('Failed to cancel local notification: $e');
    }
  }

  @override
  Future<void> cancelAllLocalNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      throw Exception('Failed to cancel all local notifications: $e');
    }
  }

  String _getChannelId(String type) {
    switch (type.toLowerCase()) {
      case NotificationConstants.typeAlert:
        return NotificationConstants.highPriorityChannelId;
      case NotificationConstants.typePromotion:
        return NotificationConstants.promotionalChannelId;
      default:
        return NotificationConstants.defaultChannelId;
    }
  }

  String _getChannelName(String type) {
    switch (type.toLowerCase()) {
      case NotificationConstants.typeAlert:
        return NotificationConstants.highPriorityChannelName;
      case NotificationConstants.typePromotion:
        return NotificationConstants.promotionalChannelName;
      default:
        return NotificationConstants.defaultChannelName;
    }
  }

  String _getChannelDescription(String type) {
    switch (type.toLowerCase()) {
      case NotificationConstants.typeAlert:
        return NotificationConstants.highPriorityChannelDescription;
      case NotificationConstants.typePromotion:
        return NotificationConstants.promotionalChannelDescription;
      default:
        return NotificationConstants.defaultChannelDescription;
    }
  }

  Importance _getImportance(String priority) {
    switch (priority.toLowerCase()) {
      case NotificationPriority.max:
        return Importance.max;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.min:
        return Importance.min;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(String priority) {
    switch (priority.toLowerCase()) {
      case NotificationPriority.max:
        return Priority.max;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.min:
        return Priority.min;
      default:
        return Priority.defaultPriority;
    }
  }
}
