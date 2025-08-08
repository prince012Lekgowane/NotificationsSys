import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/device_entity.dart';
import '../repositories/notification_repository.dart';
import '../../core/errors/failures.dart';

class GetDevices {
  final NotificationRepository repository;

  GetDevices(this.repository);

  Future<Either<Failure, List<DeviceEntity>>> call(
    GetDevicesParams params,
  ) async {
    return await repository.getDevices();
  }
}

class GetDevicesParams extends Equatable {
  const GetDevicesParams();

  @override
  List<Object?> get props => [];
}
