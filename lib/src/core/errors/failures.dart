import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic details;

  const Failure({required this.message, this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];
}

// Firebase-related failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({required super.message, super.code, super.details});
}

class TokenGenerationFailure extends FirebaseFailure {
  const TokenGenerationFailure({
    super.message = 'Failed to generate FCM token',
    super.code = 1001,
    super.details,
  });
}

class MessageSendFailure extends FirebaseFailure {
  const MessageSendFailure({
    super.message = 'Failed to send notification',
    super.code = 1002,
    super.details,
  });
}

class TopicSubscriptionFailure extends FirebaseFailure {
  const TopicSubscriptionFailure({
    super.message = 'Failed to subscribe to topic',
    super.code = 1003,
    super.details,
  });
}

// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code = 2001,
    super.details,
  });
}

class NotificationPermissionDeniedFailure extends PermissionFailure {
  const NotificationPermissionDeniedFailure({
    super.message = 'Notification permission denied',
    super.code = 2001,
    super.details,
  });
}

class NotificationPermissionPermanentlyDeniedFailure extends PermissionFailure {
  const NotificationPermissionPermanentlyDeniedFailure({
    super.message = 'Notification permission permanently denied',
    super.code = 2002,
    super.details,
  });
}

// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.details});
}

class NoInternetConnectionFailure extends NetworkFailure {
  const NoInternetConnectionFailure({
    super.message = 'No internet connection',
    super.code = 3001,
    super.details,
  });
}

class ServerFailure extends NetworkFailure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code = 3002,
    super.details,
  });
}

class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure({
    super.message = 'Request timeout',
    super.code = 3003,
    super.details,
  });
}

// Storage-related failures
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code, super.details});
}

class LocalStorageFailure extends StorageFailure {
  const LocalStorageFailure({
    super.message = 'Failed to access local storage',
    super.code = 4001,
    super.details,
  });
}

class CacheFailure extends StorageFailure {
  const CacheFailure({
    super.message = 'Cache operation failed',
    super.code = 4002,
    super.details,
  });
}

// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 5001,
    super.details,
  });
}

class InvalidNotificationDataFailure extends ValidationFailure {
  const InvalidNotificationDataFailure({
    super.message = 'Invalid notification data',
    super.code = 5001,
    super.details,
  });
}

class InvalidDeviceDataFailure extends ValidationFailure {
  const InvalidDeviceDataFailure({
    super.message = 'Invalid device data',
    super.code = 5002,
    super.details,
  });
}

class InvalidTopicNameFailure extends ValidationFailure {
  const InvalidTopicNameFailure({
    super.message = 'Invalid topic name',
    super.code = 5003,
    super.details,
  });
}

// Platform-specific failures
class PlatformFailure extends Failure {
  const PlatformFailure({required super.message, super.code, super.details});
}

class UnsupportedPlatformFailure extends PlatformFailure {
  const UnsupportedPlatformFailure({
    super.message = 'Platform not supported',
    super.code = 6001,
    super.details,
  });
}

class PlatformChannelFailure extends PlatformFailure {
  const PlatformChannelFailure({
    super.message = 'Platform channel error',
    super.code = 6002,
    super.details,
  });
}

// Generic failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code = 9999,
    super.details,
  });
}

// Extension for easy failure conversion
extension FailureExtension on Exception {
  Failure toFailure() {
    final message = toString();

    if (message.contains('permission')) {
      return NotificationPermissionDeniedFailure(details: this);
    } else if (message.contains('network') || message.contains('connection')) {
      return NoInternetConnectionFailure(details: this);
    } else if (message.contains('timeout')) {
      return TimeoutFailure(details: this);
    } else if (message.contains('server')) {
      return ServerFailure(details: this);
    } else if (message.contains('token')) {
      return TokenGenerationFailure(details: this);
    } else if (message.contains('storage')) {
      return LocalStorageFailure(details: this);
    } else {
      return UnknownFailure(message: message, details: this);
    }
  }
}
