
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/send_notification.dart';
import '../../domain/usecases/get_notifications_history.dart';
import '../../core/errors/failures.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int limit;
  final String? type;
  final DateTime? since;

  const LoadNotifications({
    this.limit = 50,
    this.type,
    this.since,
  });

  @override
  List<Object?> get props => [limit, type, since];
}

class SendNotificationEvent extends NotificationEvent {
  final NotificationEntity notification;

  const SendNotificationEvent(this.notification);

  @override
  List<Object?> get props => [notification];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationSending extends NotificationState {
  const NotificationSending();
}

class NotificationSent extends NotificationState {
  final NotificationEntity notification;

  const NotificationSent(this.notification);

  @override
  List<Object?> get props => [notification];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final SendNotification sendNotification;
  final GetNotificationsHistory getNotificationsHistory;

  NotificationBloc({
    required this.sendNotification,
    required this.getNotificationsHistory,
  }) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<SendNotificationEvent>(_onSendNotification);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await getNotificationsHistory(
      GetNotificationsHistoryParams(
        limit: event.limit,
        type: event.type,
        since: event.since,
      ),
    );

    result.fold(
      (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onSendNotification(
    SendNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationSending());

    final result = await sendNotification(event.notification);

    result.fold(
      (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
      (notification) {
        emit(NotificationSent(notification));
        // Refresh the list
        add(const RefreshNotifications());
      },
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // This would typically call a use case to mark as read
    // For now, we'll just refresh the list
    add(const RefreshNotifications());
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      add(const LoadNotifications());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case MessageSendFailure:
        return 'Failed to send notification';
      case NetworkFailure:
        return 'Network error occurred';
      case LocalStorageFailure:
        return 'Storage error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }
}