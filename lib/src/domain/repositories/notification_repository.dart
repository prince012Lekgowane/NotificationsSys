import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../entities/device_entity.dart';
import '../entities/topic_entity.dart';
import '../entities/notification_template.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationEntity>> sendNotification(
    NotificationEntity notification,
  );

  Future<Either<Failure, List<NotificationEntity>>> sendBulkNotifications(
    List<NotificationEntity> notifications,
  );

  Future<Either<Failure, NotificationEntity>> scheduleNotification(
    NotificationEntity notification,
    DateTime scheduledTime,
  );

  Future<Either<Failure, void>> cancelScheduledNotification(
      String notificationId);

  Future<Either<Failure, List<NotificationEntity>>> getScheduledNotifications();

  Future<Either<Failure, NotificationEntity?>> getNotification(
      String notificationId);

  Future<Either<Failure, List<NotificationEntity>>> getNotificationHistory({
    int limit = 50,
    String? type,
    DateTime? since,
    String? deviceId,
  });

  Future<Either<Failure, NotificationEntity>> markNotificationAsRead(
      String notificationId);

  Future<Either<Failure, void>> deleteNotification(String notificationId);

  Future<Either<Failure, NotificationAnalytics>> getNotificationAnalytics({
    String? notificationId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, DeviceEntity>> registerDevice(DeviceEntity device);

  Future<Either<Failure, void>> unregisterDevice(String deviceId);

  Future<Either<Failure, DeviceEntity>> updateDevice(DeviceEntity device);

  Future<Either<Failure, List<DeviceEntity>>> getDevices();

  Future<Either<Failure, DeviceEntity?>> getDevice(String deviceId);

  Future<Either<Failure, bool>> validateFCMToken(String token);

  Future<Either<Failure, String>> refreshFCMToken(String deviceId);

  Future<Either<Failure, void>> subscribeToTopic(
      String deviceToken, String topic);

  Future<Either<Failure, void>> unsubscribeFromTopic(
      String deviceToken, String topic);

  Future<Either<Failure, List<TopicEntity>>> getTopics();

  Future<Either<Failure, TopicEntity>> createTopic(TopicEntity topic);

  Future<Either<Failure, TopicEntity>> updateTopic(TopicEntity topic);

  Future<Either<Failure, void>> deleteTopic(String topicId);

  Future<Either<Failure, TopicAnalytics>> getTopicAnalytics(String topicId);

  Future<Either<Failure, List<TopicSubscription>>> getDeviceSubscriptions(
      String deviceId);

  Future<Either<Failure, List<DeviceEntity>>> getTopicSubscribers(
      String topicId);

  Future<Either<Failure, void>> saveNotificationSettings(
    String deviceId,
    Map<String, dynamic> settings,
  );

  Future<Either<Failure, Map<String, dynamic>>> getNotificationSettings(
      String deviceId);

  Future<Either<Failure, List<NotificationTemplate>>>
      getNotificationTemplates();

  Future<Either<Failure, NotificationTemplate>> createNotificationTemplate(
    NotificationTemplate template,
  );

  Future<Either<Failure, NotificationEntity>> sendNotificationFromTemplate(
    String templateId,
    Map<String, dynamic> variables,
    List<String>? targetDevices,
    List<String>? targetTopics,
  );
}
