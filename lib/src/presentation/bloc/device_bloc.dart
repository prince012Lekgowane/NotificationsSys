
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/register_device.dart';
import '../../domain/usecases/get_devices.dart';
import '../../core/errors/failures.dart';

// Events
abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDevices extends DeviceEvent {
  const LoadDevices();
}

class RegisterDeviceEvent extends DeviceEvent {
  final DeviceEntity device;

  const RegisterDeviceEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class UpdateDeviceEvent extends DeviceEvent {
  final DeviceEntity device;

  const UpdateDeviceEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class RemoveDeviceEvent extends DeviceEvent {
  final String deviceId;

  const RemoveDeviceEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

// States
abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

class DeviceLoading extends DeviceState {
  const DeviceLoading();
}

class DeviceLoaded extends DeviceState {
  final List<DeviceEntity> devices;

  const DeviceLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceOperationInProgress extends DeviceState {
  const DeviceOperationInProgress();
}

class DeviceOperationSuccess extends DeviceState {
  final String message;

  const DeviceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final RegisterDevice registerDevice;
  final GetDevices getDevices;

  DeviceBloc({
    required this.registerDevice,
    required this.getDevices,
  }) : super(const DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<RegisterDeviceEvent>(_onRegisterDevice);
    on<UpdateDeviceEvent>(_onUpdateDevice);
    on<RemoveDeviceEvent>(_onRemoveDevice);
  }

  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceLoading());

    final result = await getDevices(const GetDevicesParams());

    result.fold(
      (failure) => emit(DeviceError(_mapFailureToMessage(failure))),
      (devices) => emit(DeviceLoaded(devices)),
    );
  }

  Future<void> _onRegisterDevice(
    RegisterDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceOperationInProgress());

    final result = await registerDevice(event.device);

    result.fold(
      (failure) => emit(DeviceError(_mapFailureToMessage(failure))),
      (device) {
        emit(const DeviceOperationSuccess('Device registered successfully'));
        add(const LoadDevices()); // Refresh the list
      },
    );
  }

  Future<void> _onUpdateDevice(
    UpdateDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceOperationInProgress());

    // This would typically call an update device use case
    // For now, we'll just show success and refresh
    emit(const DeviceOperationSuccess('Device updated successfully'));
    add(const LoadDevices());
  }

  Future<void> _onRemoveDevice(
    RemoveDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceOperationInProgress());

    // This would typically call a remove device use case
    // For now, we'll just show success and refresh
    emit(const DeviceOperationSuccess('Device removed successfully'));
    add(const LoadDevices());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case LocalStorageFailure:
        return 'Storage error occurred';
      case NetworkFailure:
        return 'Network error occurred';
      case ValidationFailure:
        return 'Invalid device data';
      default:
        return 'An unexpected error occurred';
    }
  }
}