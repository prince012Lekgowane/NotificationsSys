
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/datasources/local_datasource.dart';
import '../../domain/usecases/send_notification.dart';
import '../../domain/usecases/register_device.dart';
import '../../domain/usecases/subscribe_to_topic.dart';
import '../../domain/usecases/get_notifications_history.dart';
import '../../domain/usecases/get_devices.dart';
import '../../presentation/bloc/notification_bloc.dart' as notification_bloc;
import '../../presentation/bloc/device_bloc.dart' as device_bloc;
import '../../presentation/bloc/topic_bloc.dart' as topic_bloc;

final GetIt getIt = GetIt.instance;

// @InjectableInit()
// Future<void> configureDependencies() async => getIt.init();

@module
abstract class RegisterModule {
  @singleton
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @singleton
  Dio get dio {
    final dio = Dio();
    dio.options.baseUrl = 'https://fcm.googleapis.com';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add interceptors for logging and error handling
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    return dio;
  }

  @singleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  @singleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin => 
      FlutterLocalNotificationsPlugin();
}

// Manual registration for cases where code generation might not work
Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  final dio = Dio();
  dio.options.baseUrl = 'https://fcm.googleapis.com';
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);
  getIt.registerSingleton<Dio>(dio);
  
  getIt.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin(),
  );
  
  // Data sources
  getIt.registerLazySingleton<FirebaseDataSource>(
    () => FirebaseDataSourceImpl(
      getIt<FirebaseMessaging>(),
      getIt<Dio>(),
    ),
  );
  
  getIt.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(
      getIt<SharedPreferences>(),
      getIt<FlutterLocalNotificationsPlugin>(),
    ),
  );
  
  // Repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      getIt<FirebaseDataSource>(),
      getIt<LocalDataSource>(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton(() => SendNotification(getIt<NotificationRepository>()));
  getIt.registerLazySingleton(() => RegisterDevice(getIt<NotificationRepository>()));
  getIt.registerLazySingleton(() => SubscribeToTopic(getIt<NotificationRepository>()));
  getIt.registerLazySingleton(() => GetNotificationsHistory(getIt<NotificationRepository>()));
  getIt.registerLazySingleton(() => GetDevices(getIt<NotificationRepository>()));
  
  // BLoCs
  getIt.registerFactory(
    () => notification_bloc.NotificationBloc(
      sendNotification: getIt<SendNotification>(),
      getNotificationsHistory: getIt<GetNotificationsHistory>(),
    ),
  );
  
  getIt.registerFactory(
    () => device_bloc.DeviceBloc(
      registerDevice: getIt<RegisterDevice>(),
      getDevices: getIt<GetDevices>(),
    ),
  );
  
  getIt.registerFactory(
    () => topic_bloc.TopicBloc(
      subscribeToTopic: getIt<SubscribeToTopic>(),
    ),
  );

}