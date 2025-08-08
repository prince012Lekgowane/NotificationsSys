import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/di/injection.dart';
import 'core/constants/constants.dart';
import 'core/errors/failures.dart';
import 'core/utils/notification_utils.dart';
import 'domain/entities/notification_entity.dart';
import 'domain/entities/device_entity.dart';
import 'domain/entities/topic_entity.dart';
import 'domain/usecases/send_notification.dart';
import 'domain/usecases/register_device.dart';
import 'domain/usecases/subscribe_to_topic.dart';
import 'domain/usecases/get_notifications_history.dart';
import 'domain/usecases/get_devices.dart';

/// Main service class for the notification system
///
/// This is the primary interface for integrating notifications into your Flutter app.
/// It provides a simple API for sending, receiving, and managing notifications
/// across Android, iOS, and Web platforms.
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  bool _isInitialized = false;
  String? _currentDeviceToken;
  StreamController<NotificationEntity>? _notificationStreamController;
  StreamController<String>? _tokenStreamController;

  // Configuration
  Map<String, dynamic> _config = {};

  // Use cases
  late SendNotification _sendNotification;
  late RegisterDevice _registerDevice;
  late SubscribeToTopic _subscribeToTopic;
  late GetNotificationsHistory _getNotificationsHistory;
  late GetDevices _getDevices;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get current device FCM token
  String? get currentDeviceToken => _currentDeviceToken;

  /// Stream of incoming notifications
  Stream<NotificationEntity> get notificationStream =>
      _notificationStreamController?.stream ?? const Stream.empty();

  /// Stream of token updates
  Stream<String> get tokenStream =>
      _tokenStreamController?.stream ?? const Stream.empty();

  /// Initialize the notification service
  ///
  /// This must be called before using any other methods.
  /// Usually called in your app's main() function or initState().
  ///
  /// [config] - Configuration map with Firebase and other settings
  ///
  /// Example:
  /// ```dart
  /// await NotificationService.instance.initialize({
  ///   'firebaseOptions': DefaultFirebaseOptions.currentPlatform,
  ///   'enableAnalytics': true,
  ///   'enableLocalNotifications': true,
  /// });
  /// ```
  Future<void> initialize([Map<String, dynamic>? config]) async {
    if (_isInitialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    try {
      _config = config ?? {};

      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        final firebaseOptions = _config['firebaseOptions'];
        if (firebaseOptions != null) {
          await Firebase.initializeApp(options: firebaseOptions);
        } else {
          await Firebase.initializeApp();
        }
      }

      // Initialize dependencies
      await initializeDependencies();

      // Get use cases from DI container
      _sendNotification = getIt<SendNotification>();
      _registerDevice = getIt<RegisterDevice>();
      _subscribeToTopic = getIt<SubscribeToTopic>();
      _getNotificationsHistory = getIt<GetNotificationsHistory>();
      _getDevices = getIt<GetDevices>();

      // Setup notification channels for Android
      await _setupNotificationChannels();

      // Setup message handlers
      await _setupMessageHandlers();

      // Initialize streams
      _notificationStreamController =
          StreamController<NotificationEntity>.broadcast();
      _tokenStreamController = StreamController<String>.broadcast();

      // Request permissions
      await requestPermissions();

      // Get and save initial FCM token
      await _refreshToken();

      // Register device
      await _registerCurrentDevice();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
      throw InitializationException(message: 'Failed to initialize: $e');
    }
  }

  /// Request notification permissions
  ///
  /// Returns true if permissions are granted, false otherwise.
  Future<bool> requestPermissions() async {
    try {
      // Request notification permission
      final notificationStatus = await Permission.notification.request();

      if (notificationStatus.isGranted) {
        // Request Firebase Messaging permission (iOS specific)
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }

      return false;
    } catch (e) {
      debugPrint('Failed to request permissions: $e');
      return false;
    }
  }

  /// Send a notification
  ///
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [data] - Additional data to include with the notification
  /// [targetDevices] - Specific device tokens to target (optional)
  /// [targetTopics] - Topics to send to (optional)
  /// [priority] - Notification priority (default: normal)
  /// [type] - Notification type for categorization
  /// [imageUrl] - URL for notification image (optional)
  /// [deepLink] - Deep link URL for when notification is tapped
  ///
  /// Example:
  /// ```dart
  /// await NotificationService.instance.send(
  ///   title: 'New Message',
  ///   body: 'You have a new message from John',
  ///   data: {'messageId': '123', 'chatId': 'abc'},
  ///   deepLink: '/chat/abc',
  ///   priority: NotificationPriority.high,
  /// );
  /// ```
  Future<NotificationEntity> send({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    List<String>? targetDevices,
    List<String>? targetTopics,
    String priority = NotificationPriority.normal,
    String type = NotificationConstants.typeGeneral,
    String? imageUrl,
    String? deepLink,
    String? sound,
    int? badge,
    DateTime? scheduledAt,
  }) async {
    _ensureInitialized();

    try {
      final notification = NotificationEntity(
        id: NotificationUtils.generateRandomString(20),
        title: title,
        body: body,
        type: type,
        priority: priority,
        status: NotificationStatus.pending,
        data: data ?? {},
        targetDevices: targetDevices ?? [],
        targetTopics: targetTopics ?? [],
        deepLink: deepLink,
        imageUrl: imageUrl,
        sound: sound,
        badge: badge,
        createdAt: DateTime.now(),
        scheduledAt: scheduledAt,
      );

      final result = await _sendNotification(notification);

      return result.fold(
        (failure) => throw NotificationException(failure.message),
        (sentNotification) => sentNotification,
      );
    } catch (e) {
      throw NotificationException('Failed to send notification: $e');
    }
  }

  /// Subscribe to a topic
  ///
  /// [topic] - Topic name to subscribe to
  ///
  /// Example:
  /// ```dart
  /// await NotificationService.instance.subscribeToTopic('news');
  /// ```
  Future<void> subscribeToTopic(String topic) async {
    _ensureInitialized();

    if (!NotificationUtils.isValidTopicName(topic)) {
      throw InvalidTopicException('Invalid topic name: $topic');
    }

    try {
      final result = await _subscribeToTopic(SubscribeToTopicParams(
        topic: topic,
        deviceToken: _currentDeviceToken!,
      ));

      result.fold(
        (failure) => throw NotificationException(failure.message),
        (_) => debugPrint('Successfully subscribed to topic: $topic'),
      );
    } catch (e) {
      throw NotificationException('Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  ///
  /// [topic] - Topic name to unsubscribe from
  Future<void> unsubscribeFromTopic(String topic) async {
    _ensureInitialized();

    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Successfully unsubscribed from topic: $topic');
    } catch (e) {
      throw NotificationException('Failed to unsubscribe from topic: $e');
    }
  }

  /// Get notification history
  ///
  /// Returns a list of previously sent/received notifications
  Future<List<NotificationEntity>> getNotificationHistory({
    int limit = 50,
    String? type,
    DateTime? since,
  }) async {
    _ensureInitialized();

    try {
      final result =
          await _getNotificationsHistory(GetNotificationsHistoryParams(
        limit: limit,
        type: type,
        since: since,
      ));

      return result.fold(
        (failure) => throw NotificationException(failure.message),
        (notifications) => notifications,
      );
    } catch (e) {
      throw NotificationException('Failed to get notification history: $e');
    }
  }

  /// Get registered devices
  ///
  /// Returns a list of devices registered for notifications
  Future<List<DeviceEntity>> getDevices() async {
    _ensureInitialized();

    try {
      final result = await _getDevices(const GetDevicesParams());

      return result.fold(
        (failure) => throw NotificationException(failure.message),
        (devices) => devices,
      );
    } catch (e) {
      throw NotificationException('Failed to get devices: $e');
    }
  }

  /// Enable/disable notifications
  ///
  /// [enabled] - Whether to enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _ensureInitialized();

    try {
      if (enabled) {
        final hasPermission = await requestPermissions();
        if (!hasPermission) {
          throw PermissionException('Notification permission denied');
        }
      }

      // Update local settings
      // This would typically be saved to local storage
      debugPrint('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      throw NotificationException('Failed to update notification settings: $e');
    }
  }

  /// Get current notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    _ensureInitialized();

    try {
      // This would typically be loaded from local storage
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
    } catch (e) {
      throw NotificationException('Failed to get notification settings: $e');
    }
  }

  /// Update notification settings
  ///
  /// [settings] - Map of settings to update
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    _ensureInitialized();

    try {
      // This would typically be saved to local storage
      debugPrint('Updated notification settings: $settings');
    } catch (e) {
      throw NotificationException('Failed to update notification settings: $e');
    }
  }

  /// Refresh FCM token
  Future<String?> refreshToken() async {
    _ensureInitialized();
    return await _refreshToken();
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController?.close();
    _tokenStreamController?.close();
    _notificationStreamController = null;
    _tokenStreamController = null;
  }

  // Private methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'NotificationService not initialized. Call initialize() first.');
    }
  }

  Future<void> _setupNotificationChannels() async {
    final flutterLocalNotificationsPlugin =
        getIt<FlutterLocalNotificationsPlugin>();

    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitializationSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channels for Android
    const defaultChannel = AndroidNotificationChannel(
      NotificationConstants.defaultChannelId,
      NotificationConstants.defaultChannelName,
      description: NotificationConstants.defaultChannelDescription,
      importance: Importance.defaultImportance,
    );

    const highPriorityChannel = AndroidNotificationChannel(
      NotificationConstants.highPriorityChannelId,
      NotificationConstants.highPriorityChannelName,
      description: NotificationConstants.highPriorityChannelDescription,
      importance: Importance.high,
    );

    const promotionalChannel = AndroidNotificationChannel(
      NotificationConstants.promotionalChannelId,
      NotificationConstants.promotionalChannelName,
      description: NotificationConstants.promotionalChannelDescription,
      importance: Importance.low,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highPriorityChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(promotionalChannel);
  }

  Future<void> _setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle app launch from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessageTap(initialMessage);
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _currentDeviceToken = token;
      _tokenStreamController?.add(token);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.notification?.title}');

    final notification = _convertRemoteMessageToEntity(message);
    _notificationStreamController?.add(notification);

    // Show local notification for foreground messages
    _showLocalNotification(message);
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');

    final notification = _convertRemoteMessageToEntity(message);
    _notificationStreamController?.add(notification);

    // Handle deep linking
    final deepLink = NotificationUtils.extractDeepLink(message.data);
    if (deepLink != null) {
      // Navigate to deep link
      debugPrint('Navigating to deep link: $deepLink');
    }
  }

  NotificationEntity _convertRemoteMessageToEntity(RemoteMessage message) {
    return NotificationEntity(
      id: message.messageId ?? NotificationUtils.generateRandomString(20),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? NotificationConstants.typeGeneral,
      priority: message.data['priority'] ?? NotificationPriority.normal,
      status: NotificationStatus.delivered,
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      deepLink: NotificationUtils.extractDeepLink(message.data),
      createdAt: message.sentTime ?? DateTime.now(),
      deliveredAt: DateTime.now(),
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final flutterLocalNotificationsPlugin =
        getIt<FlutterLocalNotificationsPlugin>();

    final androidDetails = AndroidNotificationDetails(
      NotificationUtils.getNotificationChannel(message.data['type'] ?? ''),
      NotificationConstants.defaultChannelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      NotificationUtils.generateNotificationId(),
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  Future<String?> _refreshToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      _currentDeviceToken = token;

      if (token != null) {
        _tokenStreamController?.add(token);
      }

      return token;
    } catch (e) {
      debugPrint('Failed to refresh token: $e');
      return null;
    }
  }

  Future<void> _registerCurrentDevice() async {
    if (_currentDeviceToken == null) return;

    try {
      final deviceInfo = await NotificationUtils.getDeviceInfo();

      final device = DeviceEntity(
        id: deviceInfo['deviceId'],
        fcmToken: _currentDeviceToken!,
        platform: deviceInfo['platform'],
        deviceName: deviceInfo['deviceName'],
        osVersion: deviceInfo['osVersion'],
        appVersion: deviceInfo['appVersion'],
        appBuildNumber: deviceInfo['appBuildNumber'],
        manufacturer: deviceInfo['manufacturer'],
        model: deviceInfo['model'],
        registeredAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      final result = await _registerDevice(device);

      result.fold(
        (failure) =>
            debugPrint('Failed to register device: ${failure.message}'),
        (registeredDevice) => debugPrint('Device registered successfully'),
      );
    } catch (e) {
      debugPrint('Failed to register device: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.notification?.title}');
}

// Custom exceptions
class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}

class InitializationException extends NotificationException {
  InitializationException({required String message}) : super(message);
}

class PermissionException extends NotificationException {
  PermissionException(String message) : super(message);
}

class InvalidTopicException extends NotificationException {
  InvalidTopicException(String message) : super(message);
}
