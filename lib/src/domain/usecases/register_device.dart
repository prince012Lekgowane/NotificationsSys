import 'package:dartz/dartz.dart';
import '../entities/device_entity.dart';
import '../repositories/notification_repository.dart';
import '../../core/errors/failures.dart';

class RegisterDevice {
  final NotificationRepository repository;

  RegisterDevice(this.repository);

  Future<Either<Failure, DeviceEntity>> call(DeviceEntity device) async {
    return await repository.registerDevice(device);
  }
}
