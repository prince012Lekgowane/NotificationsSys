library notification_system;

// Core Services
export 'src/core/di/injection.dart';
export 'src/core/constants/constants.dart' hide NotificationAction;
export 'src/core/errors/failures.dart';
export 'src/core/utils/notification_utils.dart';

// Domain Layer
export 'src/domain/entities/notification_entity.dart';
export 'src/domain/entities/device_entity.dart';
export 'src/domain/entities/topic_entity.dart';
export 'src/domain/repositories/notification_repository.dart';
export 'src/domain/usecases/send_notification.dart';
export 'src/domain/usecases/register_device.dart';
export 'src/domain/usecases/subscribe_to_topic.dart';
export 'src/domain/usecases/get_notifications_history.dart';
export 'src/domain/usecases/get_devices.dart';

// Data Layer Models
export 'src/data/models/notification_model.dart';
export 'src/data/models/device_model.dart';
export 'src/data/models/topic_model.dart';

// Presentation Layer
export 'src/presentation/bloc/notification_bloc.dart';
export 'src/presentation/bloc/device_bloc.dart';
export 'src/presentation/bloc/topic_bloc.dart';
export 'src/presentation/pages/notification_dashboard.dart';
export 'src/presentation/pages/device_management_page.dart';
export 'src/presentation/pages/settings_page.dart';
export 'src/presentation/widgets/notification_card.dart';
export 'src/presentation/widgets/device_card.dart';
export 'src/presentation/widgets/notification_settings.dart';

// Main Service Class
export 'src/notification_service.dart';
