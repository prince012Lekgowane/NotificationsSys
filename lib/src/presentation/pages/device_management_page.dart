import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/device_bloc.dart' as presentation;
import '../widgets/device_card.dart';
import '../../core/di/injection.dart';

class DeviceManagementPage extends StatelessWidget {
  const DeviceManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<presentation.DeviceBloc>()
        ..add(const presentation.LoadDevices()),
      child: const _DeviceManagementView(),
    );
  }
}

class _DeviceManagementView extends StatelessWidget {
  const _DeviceManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<presentation.DeviceBloc>()
                  .add(const presentation.LoadDevices());
            },
          ),
        ],
      ),
      body: BlocBuilder<presentation.DeviceBloc, presentation.DeviceState>(
        builder: (context, state) {
          if (state is presentation.DeviceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is presentation.DeviceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<presentation.DeviceBloc>()
                          .add(const presentation.LoadDevices());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is presentation.DeviceLoaded) {
            if (state.devices.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.devices, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No Devices Registered'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final device = state.devices[index];
                return DeviceCard(device: device);
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
