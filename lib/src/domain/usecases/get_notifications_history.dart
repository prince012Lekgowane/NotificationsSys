
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import '../../core/errors/failures.dart';

class GetNotificationsHistory {
  final NotificationRepository repository;

  GetNotificationsHistory(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(GetNotificationsHistoryParams params) async {
    return await repository.getNotificationHistory(
      limit: params.limit,
      type: params.type,
      since: params.since,
      deviceId: params.deviceId,
    );
  }
}

class GetNotificationsHistoryParams extends Equatable {
  final int limit;
  final String? type;
  final DateTime? since;
  final String? deviceId;

  const GetNotificationsHistoryParams({
    this.limit = 50,
    this.type,
    this.since,
    this.deviceId,
  });

  @override
  List<Object?> get props => [limit, type, since, deviceId];
}