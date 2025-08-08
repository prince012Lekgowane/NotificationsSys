
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/notification_repository.dart';
import '../../core/errors/failures.dart';

class SubscribeToTopic {
  final NotificationRepository repository;

  SubscribeToTopic(this.repository);

  Future<Either<Failure, void>> call(SubscribeToTopicParams params) async {
    return await repository.subscribeToTopic(params.deviceToken, params.topic);
  }
}

class SubscribeToTopicParams extends Equatable {
  final String deviceToken;
  final String topic;

  const SubscribeToTopicParams({
    required this.deviceToken,
    required this.topic,
  });

  @override
  List<Object?> get props => [deviceToken, topic];
}