
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/notification_utils.dart';

class SendNotification {
  final NotificationRepository repository;

  SendNotification(this.repository);

  Future<Either<Failure, NotificationEntity>> call(NotificationEntity notification) async {
    // Validate notification data
    final validationResult = _validateNotification(notification);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Sanitize notification data
    final sanitizedNotification = _sanitizeNotification(notification);

    // Send the notification
    return await repository.sendNotification(sanitizedNotification);
  }

  Failure? _validateNotification(NotificationEntity notification) {
    // Check if title and body are provided
    if (notification.title.trim().isEmpty) {
      return const InvalidNotificationDataFailure(
        message: 'Notification title cannot be empty',
      );
    }

    if (notification.body.trim().isEmpty) {
      return const InvalidNotificationDataFailure(
        message: 'Notification body cannot be empty',
      );
    }

    // Check if at least one target is specified
    if (notification.targetDevices.isEmpty && notification.targetTopics.isEmpty) {
      return const InvalidNotificationDataFailure(
        message: 'At least one target device or topic must be specified',
      );
    }

    // Validate topic names
    for (final topic in notification.targetTopics) {
      if (!NotificationUtils.isValidTopicName(topic)) {
        return InvalidTopicNameFailure(
          message: 'Invalid topic name: $topic',
        );
      }
    }

    // Validate payload size
    if (!NotificationUtils.isValidPayloadSize(notification.data)) {
      return const InvalidNotificationDataFailure(
        message: 'Notification payload exceeds size limit (4KB)',
      );
    }

    // Validate scheduled time if provided
    if (notification.scheduledAt != null) {
      final now = DateTime.now();
      if (notification.scheduledAt!.isBefore(now)) {
        return const InvalidNotificationDataFailure(
          message: 'Scheduled time cannot be in the past',
        );
      }

      // Check if scheduled time is too far in the future (FCM limit is 28 days)
      final maxScheduledTime = now.add(const Duration(days: 28));
      if (notification.scheduledAt!.isAfter(maxScheduledTime)) {
        return const InvalidNotificationDataFailure(
          message: 'Scheduled time cannot be more than 28 days in the future',
        );
      }
    }

    return null; // No validation errors
  }

  NotificationEntity _sanitizeNotification(NotificationEntity notification) {
    // Sanitize title and body
    final sanitizedTitle = notification.title.trim();
    final sanitizedBody = notification.body.trim();

    // Sanitize data payload
    final sanitizedData = NotificationUtils.sanitizeNotificationData(notification.data);

    // Ensure required fields are set
    final sanitizedNotification = notification.copyWith(
      title: sanitizedTitle,
      body: sanitizedBody,
      data: sanitizedData,
      createdAt: notification.createdAt,
      status: NotificationStatus.pending,
    );

    return sanitizedNotification;
  }
}

// Use case for sending bulk notifications
class SendBulkNotifications {
  final NotificationRepository repository;

  SendBulkNotifications(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(
    SendBulkNotificationsParams params,
  ) async {
    // Validate all notifications
    for (final notification in params.notifications) {
      final sendNotification = SendNotification(repository);
      final validationResult = sendNotification._validateNotification(notification);
      if (validationResult != null) {
        return Left(validationResult);
      }
    }

    // Send bulk notifications
    return await repository.sendBulkNotifications(params.notifications);
  }
}

// Use case for sending notifications from template
class SendNotificationFromTemplate {
  final NotificationRepository repository;

  SendNotificationFromTemplate(this.repository);

  Future<Either<Failure, NotificationEntity>> call(
    SendNotificationFromTemplateParams params,
  ) async {
    return await repository.sendNotificationFromTemplate(
      params.templateId,
      params.variables,
      params.targetDevices,
      params.targetTopics,
    );
  }
}

// Use case for scheduling notifications
class ScheduleNotification {
  final NotificationRepository repository;

  ScheduleNotification(this.repository);

  Future<Either<Failure, NotificationEntity>> call(
    ScheduleNotificationParams params,
  ) async {
    // Validate scheduled time
    final now = DateTime.now();
    if (params.scheduledTime.isBefore(now)) {
      return const Left(InvalidNotificationDataFailure(
        message: 'Scheduled time cannot be in the past',
      ));
    }

    // Update notification with scheduled time
    final scheduledNotification = params.notification.copyWith(
      scheduledAt: params.scheduledTime,
      status: NotificationStatus.pending,
    );

    return await repository.scheduleNotification(
      scheduledNotification,
      params.scheduledTime,
    );
  }
}

// Parameters classes
class SendBulkNotificationsParams extends Equatable {
  final List<NotificationEntity> notifications;

  const SendBulkNotificationsParams({
    required this.notifications,
  });

  @override
  List<Object?> get props => [notifications];
}

class SendNotificationFromTemplateParams extends Equatable {
  final String templateId;
  final Map<String, dynamic> variables;
  final List<String>? targetDevices;
  final List<String>? targetTopics;

  const SendNotificationFromTemplateParams({
    required this.templateId,
    required this.variables,
    this.targetDevices,
    this.targetTopics,
  });

  @override
  List<Object?> get props => [templateId, variables, targetDevices, targetTopics];
}

class ScheduleNotificationParams extends Equatable {
  final NotificationEntity notification;
  final DateTime scheduledTime;

  const ScheduleNotificationParams({
    required this.notification,
    required this.scheduledTime,
  });

  @override
  List<Object?> get props => [notification, scheduledTime];
}