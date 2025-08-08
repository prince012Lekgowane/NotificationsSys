import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../models/notification_model.dart';

abstract class FirebaseDataSource {
  Future<String?> getFCMToken();
  Future<void> subscribeToTopic(String token, String topic);
  Future<void> unsubscribeFromTopic(String token, String topic);
  Future<void> sendNotification(NotificationModel notification);
  Future<void> sendBulkNotifications(List<NotificationModel> notifications);
  Future<bool> validateToken(String token);
}

class FirebaseDataSourceImpl implements FirebaseDataSource {
  final FirebaseMessaging firebaseMessaging;
  final Dio dio;

  FirebaseDataSourceImpl(this.firebaseMessaging, this.dio);

  @override
  Future<String?> getFCMToken() async {
    try {
      return await firebaseMessaging.getToken();
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String token, String topic) async {
    try {
      await firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String token, String topic) async {
    try {
      await firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  @override
  Future<void> sendNotification(NotificationModel notification) async {
    try {
      final payload = _buildNotificationPayload(notification);

      final response = await dio.post(
        '/fcm/send',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=YOUR_SERVER_KEY', // This should be configured
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  @override
  Future<void> sendBulkNotifications(
    List<NotificationModel> notifications,
  ) async {
    try {
      for (final notification in notifications) {
        await sendNotification(notification);
      }
    } catch (e) {
      throw Exception('Failed to send bulk notifications: $e');
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      // This would typically involve a server-side validation
      // For now, we just check if the token is not empty and has a valid format
      return token.isNotEmpty && token.length > 100;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _buildNotificationPayload(
    NotificationModel notification,
  ) {
    final payload = <String, dynamic>{
      'notification': {'title': notification.title, 'body': notification.body},
      'data': notification.data,
    };

    // Add targeting
    if (notification.targetDevices.isNotEmpty) {
      if (notification.targetDevices.length == 1) {
        payload['to'] = notification.targetDevices.first;
      } else {
        payload['registration_ids'] = notification.targetDevices;
      }
    } else if (notification.targetTopics.isNotEmpty) {
      if (notification.targetTopics.length == 1) {
        payload['to'] = '/topics/${notification.targetTopics.first}';
      } else {
        // For multiple topics, we'd need to send separate requests
        // or use condition targeting
        final condition = notification.targetTopics
            .map((topic) => "'$topic' in topics")
            .join(' || ');
        payload['condition'] = condition;
      }
    }

    // Add Android-specific options
    payload['android'] = {
      'priority': _mapPriorityToAndroid(notification.priority),
      'notification': {
        'channel_id': _getChannelId(notification.type),
        'sound': notification.sound ?? 'default',
        'color': notification.color,
        'tag': notification.tag,
      },
    };

    // Add iOS-specific options
    payload['apns'] = {
      'headers': {'apns-priority': _mapPriorityToiOS(notification.priority)},
      'payload': {
        'aps': {
          'sound': notification.sound ?? 'default',
          'badge': notification.badge,
        },
      },
    };

    // Add image if present
    if (notification.imageUrl != null) {
      payload['notification']['image'] = notification.imageUrl;
    }

    return payload;
  }

  String _mapPriorityToAndroid(String priority) {
    switch (priority.toLowerCase()) {
      case 'max':
      case 'high':
        return 'high';
      case 'low':
      case 'min':
        return 'normal';
      default:
        return 'normal';
    }
  }

  String _mapPriorityToiOS(String priority) {
    switch (priority.toLowerCase()) {
      case 'max':
      case 'high':
        return '10';
      case 'low':
      case 'min':
        return '5';
      default:
        return '5';
    }
  }

  String _getChannelId(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return 'high_priority_channel';
      case 'promotion':
        return 'promotional_channel';
      default:
        return 'default_notification_channel';
    }
  }
}
