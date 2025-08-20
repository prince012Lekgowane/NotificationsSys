class NotificationConstants {
  // Firebase Configuration
  static const String fcmServerKey = 'AAAAXXX...'; // Replace with your actual FCM server key
  static const String fcmSenderId = '123456789012'; // Replace with your actual sender ID

  // API Endpoints
  static const String baseUrl = 'https://fcm.googleapis.com';
  static const String sendEndpoint = '/fcm/send';
  static const String subscribeEndpoint = '/fcm/notification';

  // Storage Keys
  static const String deviceTokenKey = 'device_token';
  static const String deviceIdKey = 'device_id';
  static const String notificationHistoryKey = 'notification_history';
  static const String subscribedTopicsKey = 'subscribed_topics';
  static const String notificationSettingsKey = 'notification_settings';

  // Notification Channels
  static const String defaultChannelId = 'default_notification_channel';
  static const String defaultChannelName = 'Default Notifications';
  static const String defaultChannelDescription =
      'Default notification channel for the app';

  static const String highPriorityChannelId = 'high_priority_channel';
  static const String highPriorityChannelName = 'High Priority Notifications';
  static const String highPriorityChannelDescription =
      'High priority notifications';

  static const String promotionalChannelId = 'promotional_channel';
  static const String promotionalChannelName = 'Promotional Notifications';
  static const String promotionalChannelDescription =
      'Promotional and marketing notifications';

  // Notification Types
  static const String typeGeneral = 'general';
  static const String typePromotion = 'promotion';
  static const String typeAlert = 'alert';
  static const String typeMessage = 'message';
  static const String typeReminder = 'reminder';

  // Topics
  static const String topicNews = 'news';
  static const String topicPromotions = 'promotions';
  static const String topicAlerts = 'alerts';
  static const String topicUpdates = 'updates';

  // Limits
  static const int maxNotificationHistory = 100;
  static const int maxTopicsPerDevice = 50;
  static const Duration tokenRefreshInterval = Duration(hours: 24);

  // Error Messages
  static const String permissionDeniedError = 'Notification permission denied';
  static const String tokenGenerationError = 'Failed to generate FCM token';
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String invalidDataError = 'Invalid notification data';

  // Success Messages
  static const String notificationSentSuccess =
      'Notification sent successfully';
  static const String deviceRegisteredSuccess =
      'Device registered successfully';
  static const String topicSubscribedSuccess =
      'Successfully subscribed to topic';
  static const String topicUnsubscribedSuccess =
      'Successfully unsubscribed from topic';
}

class NotificationPriority {
  static const String min = 'min';
  static const String low = 'low';
  static const String normal = 'normal';
  static const String high = 'high';
  static const String max = 'max';
}

class NotificationStatus {
  static const String pending = 'pending';
  static const String sent = 'sent';
  static const String delivered = 'delivered';
  static const String read = 'read';
  static const String failed = 'failed';
}

class DeviceType {
  static const String android = 'android';
  static const String ios = 'ios';
  static const String web = 'web';
}

class NotificationActionConstants {
  static const String open = 'open';
  static const String dismiss = 'dismiss';
  static const String reply = 'reply';
  static const String markAsRead = 'mark_as_read';
}
