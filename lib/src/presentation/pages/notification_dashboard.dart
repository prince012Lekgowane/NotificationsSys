import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notification_bloc.dart' as presentation;
import '../widgets/notification_card.dart';
import '../../core/di/injection.dart';
import '../../core/constants/constants.dart';

class NotificationDashboard extends StatelessWidget {
  const NotificationDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<presentation.NotificationBloc>()
        ..add(const presentation.LoadNotifications()),
      child: const _NotificationDashboardView(),
    );
  }
}

class _NotificationDashboardView extends StatelessWidget {
  const _NotificationDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<presentation.NotificationBloc>().add(
                    const presentation.RefreshNotifications(),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<presentation.NotificationBloc,
          presentation.NotificationState>(
        builder: (context, state) {
          if (state is presentation.NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is presentation.NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<presentation.NotificationBloc>().add(
                            const presentation.LoadNotifications(),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is presentation.NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You have no notifications yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<presentation.NotificationBloc>().add(
                      const presentation.RefreshNotifications(),
                    );
              },
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<presentation.NotificationBloc>().add(
                              presentation.MarkNotificationAsRead(
                                  notification.id),
                            );
                      }
                    },
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSendNotificationDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Send Test Notification',
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send Test Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  bodyController.text.isNotEmpty) {
                // This would create and send a notification
                // For demo purposes, we'll just close the dialog
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
