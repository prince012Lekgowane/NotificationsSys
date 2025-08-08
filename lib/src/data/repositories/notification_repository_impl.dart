
import 'package:dartz/dartz.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/topic_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../core/constants/constants.dart';
import '../../core/errors/failures.dart';
import '../datasources/firebase_datasource.dart';
import '../datasources/local_datasource.dart';
import '../models/notification_model.dart';
import '../models/device_model.dart';
import '../models/topic_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseDataSource firebaseDataSource;
  final LocalDataSource localDataSource;

  NotificationRepositoryImpl(this.firebaseDataSource, this.localDataSource);

  @override
  Future<Either<Failure, NotificationEntity>> sendNotification(
    NotificationEntity notification,
  ) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);
      
      // Send via Firebase
      await firebaseDataSource.sendNotification(notificationModel);
      
      // Update status and save locally
      final sentNotification = notificationModel.copyWith(
        status: NotificationStatus.sent,
        sentAt: DateTime.now(),
      );
      
      await localDataSource.saveNotification(sentNotification);
      
      return Right(sentNotification.toEntity());
    } catch (e) {
      return Left(MessageSendFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> registerDevice(DeviceEntity device) async {
    try {
      final deviceModel = DeviceModel.fromEntity(device);
      await localDataSource.saveDevice(deviceModel);
      return Right(device);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterDevice(String deviceId) async {
    try {
      await localDataSource.removeDevice(deviceId);
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> updateDevice(DeviceEntity device) async {
    try {
      final deviceModel = DeviceModel.fromEntity(device);
      await localDataSource.saveDevice(deviceModel);
      return Right(device);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDevices() async {
    try {
      final deviceModels = await localDataSource.getAllDevices();
      final devices = deviceModels.map((model) => model.toEntity()).toList();
      return Right(devices);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceEntity?>> getDevice(String deviceId) async {
    try {
      final deviceModel = await localDataSource.getDevice(deviceId);
      return Right(deviceModel?.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToTopic(String deviceToken, String topic) async {
    try {
      await firebaseDataSource.subscribeToTopic(deviceToken, topic);
      return const Right(null);
    } catch (e) {
      return Left(TopicSubscriptionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(String deviceToken, String topic) async {
    try {
      await firebaseDataSource.unsubscribeFromTopic(deviceToken, topic);
      return const Right(null);
    } catch (e) {
      return Left(TopicSubscriptionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopicEntity>>> getTopics() async {
    try {
      final topicModels = await localDataSource.getTopics();
      final topics = topicModels.map((model) => model.toEntity()).toList();
      return Right(topics);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TopicEntity>> createTopic(TopicEntity topic) async {
    try {
      final topicModel = TopicModel.fromEntity(topic);
      await localDataSource.addTopic(topicModel);
      return Right(topic);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TopicEntity>> updateTopic(TopicEntity topic) async {
    try {
      final topicModel = TopicModel.fromEntity(topic);
      await localDataSource.addTopic(topicModel);
      return Right(topic);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTopic(String topicId) async {
    try {
      await localDataSource.removeTopic(topicId);
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotificationHistory({
    int limit = 50,
    String? type,
    DateTime? since,
    String? deviceId,
  }) async {
    try {
      final notificationModels = await localDataSource.getNotificationHistory(limit: limit);
      var notifications = notificationModels.map((model) => model.toEntity()).toList();
      
      // Apply filters
      if (type != null) {
        notifications = notifications.where((n) => n.type == type).toList();
      }
      
      if (since != null) {
        notifications = notifications.where((n) => n.createdAt.isAfter(since)).toList();
      }
      
      return Right(notifications);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity?>> getNotification(String notificationId) async {
    try {
      final notificationModel = await localDataSource.getNotification(notificationId);
      return Right(notificationModel?.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markNotificationAsRead(String notificationId) async {
    try {
      final notificationModel = await localDataSource.getNotification(notificationId);
      if (notificationModel == null) {
        return const Left(ValidationFailure(message: 'Notification not found'));
      }
      
      final updatedNotification = notificationModel.copyWith(
        isRead: true,
        readAt: DateTime.now(),
        status: NotificationStatus.read,
      );
      
      await localDataSource.saveNotification(updatedNotification);
      return Right(updatedNotification.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await localDataSource.removeNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationAnalytics>> getNotificationAnalytics({
    String? notificationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // This is a simplified implementation
      // In a real app, you'd have more sophisticated analytics
      final analytics = NotificationAnalytics(
        sentCount: 0,
        deliveredCount: 0,
        readCount: 0,
        clickedCount: 0,
        dismissedCount: 0,
        deliveryRate: 0.0,
        openRate: 0.0,
        clickThroughRate: 0.0,
        lastUpdated: DateTime.now(),
      );
      
      return Right(analytics);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics() async {
    try {
      final devices = await localDataSource.getAllDevices();
      final activeDevices = devices.where((d) => d.isActive).length;
      
      final statistics = DeviceStatistics(
        totalDevices: devices.length,
        activeDevices: activeDevices,
        inactiveDevices: devices.length - activeDevices,
        activeRate: devices.isNotEmpty ? activeDevices / devices.length : 0.0,
        lastUpdated: DateTime.now(),
      );
      
      return Right(statistics);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TopicAnalytics>> getTopicAnalytics(String topicId) async {
    try {
      // This is a simplified implementation
      final analytics = TopicAnalytics(
        topicId: topicId,
        lastUpdated: DateTime.now(),
      );
      
      return Right(analytics);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveNotificationSettings(
    String deviceId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await localDataSource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getNotificationSettings(String deviceId) async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> scheduleNotification(
    NotificationEntity notification,
    DateTime scheduledTime,
  ) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);
      final scheduledNotification = notificationModel.copyWith(
        scheduledAt: scheduledTime,
        status: NotificationStatus.pending,
      );
      
      await localDataSource.saveNotification(scheduledNotification);
      return Right(scheduledNotification.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelScheduledNotification(String notificationId) async {
    try {
      await localDataSource.removeNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getScheduledNotifications() async {
    try {
      final notificationModels = await localDataSource.getNotificationHistory();
      final scheduledNotifications = notificationModels
          .where((n) => n.scheduledAt != null && n.status == NotificationStatus.pending)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(scheduledNotifications);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> sendBulkNotifications(
    List<NotificationEntity> notifications,
  ) async {
    try {
      final notificationModels = notifications.map(NotificationModel.fromEntity).toList();
      await firebaseDataSource.sendBulkNotifications(notificationModels);
      
      final sentNotifications = notificationModels.map((n) => n.copyWith(
        status: NotificationStatus.sent,
        sentAt: DateTime.now(),
      )).toList();
      
      for (final notification in sentNotifications) {
        await localDataSource.saveNotification(notification);
      }
      
      return Right(sentNotifications.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(MessageSendFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> trackNotificationDelivery(
    String notificationId,
    String status,
    DateTime timestamp,
  ) async {
    try {
      final notificationModel = await localDataSource.getNotification(notificationId);
      if (notificationModel != null) {
        final updatedNotification = notificationModel.copyWith(
          status: status,
          deliveredAt: status == NotificationStatus.delivered ? timestamp : null,
        );
        await localDataSource.saveNotification(updatedNotification);
      }
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> trackNotificationInteraction(
    String notificationId,
    String action,
    DateTime timestamp,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      final notificationModel = await localDataSource.getNotification(notificationId);
      if (notificationModel != null) {
        final analytics = Map<String, dynamic>.from(notificationModel.analytics);
        analytics[action] = timestamp.toIso8601String();
        if (metadata != null) {
          analytics.addAll(metadata);
        }
        
        final updatedNotification = notificationModel.copyWith(analytics: analytics);
        await localDataSource.saveNotification(updatedNotification);
      }
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopicSubscription>>> getDeviceSubscriptions(String deviceId) async {
    try {
      // This would typically be implemented with a proper backend
      return const Right([]);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getTopicSubscribers(String topicId) async {
    try {
      // This would typically be implemented with a proper backend
      return const Right([]);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateFCMToken(String token) async {
    try {
      final isValid = await firebaseDataSource.validateToken(token);
      return Right(isValid);
    } catch (e) {
      return Left(TokenGenerationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshFCMToken(String deviceId) async {
    try {
      final token = await firebaseDataSource.getFCMToken();
      if (token == null) {
        return const Left(TokenGenerationFailure());
      }
      return Right(token);
    } catch (e) {
      return Left(TokenGenerationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationTemplate>>> getNotificationTemplates() async {
    try {
      // This would typically be implemented with a proper backend
      return const Right([]);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationTemplate>> createNotificationTemplate(
    NotificationTemplate template,
  ) async {
    try {
      // This would typically be implemented with a proper backend
      return Right(template);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> sendNotificationFromTemplate(
    String templateId,
    Map<String, dynamic> variables,
    List<String>? targetDevices,
    List<String>? targetTopics,
  ) async {
    try {
      // This would typically fetch the template and process it
      // For now, we'll create a basic notification
      final notification = NotificationEntity(
        id: 'template_$templateId',
        title: 'Template Notification',
        body: 'Notification from template $templateId',
        type: NotificationConstants.typeGeneral,
        priority: NotificationPriority.normal,
        status: NotificationStatus.pending,
        data: variables,
        targetDevices: targetDevices ?? [],
        targetTopics: targetTopics ?? [],
        createdAt: DateTime.now(),
      );
      
      return await sendNotification(notification);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}