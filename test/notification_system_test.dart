import 'package:flutter_test/flutter_test.dart';
import 'package:notification_system/notification_system.dart';

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService.instance;
    });

    test('should be a singleton', () {
      final instance1 = NotificationService.instance;
      final instance2 = NotificationService.instance;

      expect(instance1, equals(instance2));
    });

    test('should not be initialized by default', () {
      expect(notificationService.isInitialized, false);
    });

    test('should have null token initially', () {
      expect(notificationService.currentDeviceToken, isNull);
    });
  });

  group('NotificationUtils', () {
    test('should generate valid notification ID', () {
      final id1 = NotificationUtils.generateNotificationId();
      final id2 = NotificationUtils.generateNotificationId();

      expect(id1, isA<int>());
      expect(id2, isA<int>());
      expect(id1, isNot(equals(id2))); // Should be different
    });

    test('should generate random string of specified length', () {
      final str1 = NotificationUtils.generateRandomString(10);
      final str2 = NotificationUtils.generateRandomString(20);

      expect(str1.length, equals(10));
      expect(str2.length, equals(20));
      expect(str1, isNot(equals(str2)));
    });

    test('should validate notification data correctly', () {
      final validData = {'title': 'Test Title', 'body': 'Test Body'};

      final invalidData1 = <String, dynamic>{};
      final invalidData2 = {'title': '', 'body': 'Test Body'};

      expect(NotificationUtils.isValidNotificationData(validData), true);
      expect(NotificationUtils.isValidNotificationData(invalidData1), false);
      expect(NotificationUtils.isValidNotificationData(invalidData2), false);
    });

    test('should validate topic names correctly', () {
      expect(NotificationUtils.isValidTopicName('news'), true);
      expect(NotificationUtils.isValidTopicName('user_123'), true);
      expect(NotificationUtils.isValidTopicName('test-topic'), true);

      expect(NotificationUtils.isValidTopicName(''), false);
      expect(NotificationUtils.isValidTopicName('invalid topic'), false);
      expect(NotificationUtils.isValidTopicName('topic with spaces'), false);
    });

    test('should format timestamps correctly', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneDayAgo = now.subtract(const Duration(days: 1));
      final oneWeekAgo = now.subtract(const Duration(days: 8));

      expect(NotificationUtils.formatTimestamp(now), contains('now'));
      expect(NotificationUtils.formatTimestamp(oneHourAgo), contains('hour'));
      expect(NotificationUtils.formatTimestamp(oneDayAgo), contains('day'));
      expect(
        NotificationUtils.formatTimestamp(oneWeekAgo),
        isNot(contains('ago')),
      );
    });

    test('should get correct notification channel for type', () {
      expect(
        NotificationUtils.getNotificationChannel(
          NotificationConstants.typeAlert,
        ),
        equals(NotificationConstants.highPriorityChannelId),
      );

      expect(
        NotificationUtils.getNotificationChannel(
          NotificationConstants.typePromotion,
        ),
        equals(NotificationConstants.promotionalChannelId),
      );

      expect(
        NotificationUtils.getNotificationChannel(
          NotificationConstants.typeGeneral,
        ),
        equals(NotificationConstants.defaultChannelId),
      );
    });

    test('should sanitize notification data', () {
      final unsafeData = {
        'title': '<script>alert("hack")</script>Title',
        'body': 'javascript:void(0)',
        'unsafe_key': 'should be removed',
        'url': 'https://safe-url.com',
      };

      final sanitized = NotificationUtils.sanitizeNotificationData(unsafeData);

      expect(sanitized['title'], equals('Title'));
      expect(sanitized['body'], equals(''));
      expect(sanitized.containsKey('unsafe_key'), false);
      expect(sanitized['url'], equals('https://safe-url.com'));
    });
  });

  group('NotificationEntity', () {
    test('should create notification entity correctly', () {
      final notification = NotificationEntity(
        id: 'test_id',
        title: 'Test Title',
        body: 'Test Body',
        type: NotificationConstants.typeGeneral,
        priority: NotificationPriority.normal,
        status: NotificationStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(notification.id, equals('test_id'));
      expect(notification.title, equals('Test Title'));
      expect(notification.body, equals('Test Body'));
      expect(notification.isRead, false);
      expect(notification.priorityLevel, equals(3));
    });

    test('should mark notification as read', () {
      final notification = NotificationEntity(
        id: 'test_id',
        title: 'Test Title',
        body: 'Test Body',
        type: NotificationConstants.typeGeneral,
        priority: NotificationPriority.normal,
        status: NotificationStatus.pending,
        createdAt: DateTime.now(),
      );

      final readNotification = notification.markAsRead();

      expect(readNotification.isRead, true);
      expect(readNotification.status, equals(NotificationStatus.read));
      expect(readNotification.readAt, isNotNull);
    });

    test('should calculate age correctly', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 2));
      final notification = NotificationEntity(
        id: 'test_id',
        title: 'Test Title',
        body: 'Test Body',
        type: NotificationConstants.typeGeneral,
        priority: NotificationPriority.normal,
        status: NotificationStatus.pending,
        createdAt: pastTime,
      );

      final age = notification.age;
      expect(age.inHours, greaterThanOrEqualTo(1));
    });
  });

  group('DeviceEntity', () {
    test('should create device entity correctly', () {
      final device = DeviceEntity(
        id: 'device_123',
        fcmToken: 'test_token',
        platform: DeviceType.android,
        deviceName: 'Test Device',
        osVersion: '11.0',
        appVersion: '1.0.0',
        appBuildNumber: '1',
        registeredAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      expect(device.id, equals('device_123'));
      expect(device.platform, equals(DeviceType.android));
      expect(device.isActive, true);
      expect(device.platformIcon, equals('android'));
    });

    test('should subscribe and unsubscribe from topics', () {
      final device = DeviceEntity(
        id: 'device_123',
        fcmToken: 'test_token',
        platform: DeviceType.android,
        deviceName: 'Test Device',
        osVersion: '11.0',
        appVersion: '1.0.0',
        appBuildNumber: '1',
        registeredAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      final subscribedDevice = device.subscribeToTopic('news');
      expect(subscribedDevice.subscribedTopics, contains('news'));

      final unsubscribedDevice = subscribedDevice.unsubscribeFromTopic('news');
      expect(unsubscribedDevice.subscribedTopics, isNot(contains('news')));
    });
  });

  group('TopicEntity', () {
    test('should create topic entity correctly', () {
      final topic = TopicEntity(
        id: 'topic_1',
        name: 'news',
        displayName: 'News',
        description: 'Latest news',
        category: 'news',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subscriberCount: 100,
      );

      expect(topic.id, equals('topic_1'));
      expect(topic.name, equals('news'));
      expect(topic.categoryIcon, equals('news'));
      expect(topic.categoryColor, equals('blue'));
      expect(topic.isPopular, false); // 100 < 1000
    });

    test('should increment and decrement subscriber count', () {
      final topic = TopicEntity(
        id: 'topic_1',
        name: 'news',
        displayName: 'News',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subscriberCount: 100,
      );

      final incrementedTopic = topic.incrementSubscriberCount();
      expect(incrementedTopic.subscriberCount, equals(101));

      final decrementedTopic = incrementedTopic.decrementSubscriberCount();
      expect(decrementedTopic.subscriberCount, equals(100));
    });
  });
}
