import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/topic_entity.dart';
import '../../domain/usecases/subscribe_to_topic.dart';
import '../../core/errors/failures.dart';

// Events
abstract class TopicEvent extends Equatable {
  const TopicEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopics extends TopicEvent {
  const LoadTopics();
}

class SubscribeToTopicEvent extends TopicEvent {
  final String topic;
  final String deviceToken;

  const SubscribeToTopicEvent({required this.topic, required this.deviceToken});

  @override
  List<Object?> get props => [topic, deviceToken];
}

class UnsubscribeFromTopicEvent extends TopicEvent {
  final String topic;
  final String deviceToken;

  const UnsubscribeFromTopicEvent({
    required this.topic,
    required this.deviceToken,
  });

  @override
  List<Object?> get props => [topic, deviceToken];
}

// States
abstract class TopicState extends Equatable {
  const TopicState();

  @override
  List<Object?> get props => [];
}

class TopicInitial extends TopicState {
  const TopicInitial();
}

class TopicLoading extends TopicState {
  const TopicLoading();
}

class TopicLoaded extends TopicState {
  final List<TopicEntity> topics;

  const TopicLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

class TopicOperationInProgress extends TopicState {
  const TopicOperationInProgress();
}

class TopicOperationSuccess extends TopicState {
  final String message;

  const TopicOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TopicError extends TopicState {
  final String message;

  const TopicError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TopicBloc extends Bloc<TopicEvent, TopicState> {
  final SubscribeToTopic subscribeToTopic;

  TopicBloc({required this.subscribeToTopic}) : super(const TopicInitial()) {
    on<LoadTopics>(_onLoadTopics);
    on<SubscribeToTopicEvent>(_onSubscribeToTopic);
    on<UnsubscribeFromTopicEvent>(_onUnsubscribeFromTopic);
  }

  Future<void> _onLoadTopics(LoadTopics event, Emitter<TopicState> emit) async {
    emit(const TopicLoading());

    // This would typically load topics from a repository
    // For now, we'll create some sample topics
    final topics = [
      TopicEntity(
        id: '1',
        name: 'news',
        displayName: 'News',
        description: 'General news and updates',
        category: 'news',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subscriberCount: 1250,
      ),
      TopicEntity(
        id: '2',
        name: 'promotions',
        displayName: 'Promotions',
        description: 'Special offers and promotions',
        category: 'promotions',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subscriberCount: 890,
      ),
      TopicEntity(
        id: '3',
        name: 'alerts',
        displayName: 'Alerts',
        description: 'Important alerts and notifications',
        category: 'alerts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subscriberCount: 2100,
      ),
    ];

    emit(TopicLoaded(topics));
  }

  Future<void> _onSubscribeToTopic(
    SubscribeToTopicEvent event,
    Emitter<TopicState> emit,
  ) async {
    emit(const TopicOperationInProgress());

    final result = await subscribeToTopic(
      SubscribeToTopicParams(
        topic: event.topic,
        deviceToken: event.deviceToken,
      ),
    );

    result.fold((failure) => emit(TopicError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(TopicOperationSuccess('Successfully subscribed to ${event.topic}'));
      add(const LoadTopics()); // Refresh the list
    });
  }

  Future<void> _onUnsubscribeFromTopic(
    UnsubscribeFromTopicEvent event,
    Emitter<TopicState> emit,
  ) async {
    emit(const TopicOperationInProgress());

    // This would typically call an unsubscribe use case
    // For now, we'll just show success
    emit(
      TopicOperationSuccess('Successfully unsubscribed from ${event.topic}'),
    );
    add(const LoadTopics());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case TopicSubscriptionFailure:
        return 'Failed to subscribe to topic';
      case NetworkFailure:
        return 'Network error occurred';
      case ValidationFailure:
        return 'Invalid topic name';
      default:
        return 'An unexpected error occurred';
    }
  }
}
