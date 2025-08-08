
import 'package:flutter/material.dart';
import '../../domain/entities/device_entity.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity device;

  const DeviceCard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(_getPlatformIcon()),
        title: Text(device.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: ${device.platform}'),
            Text('Last Active: ${_formatDate(device.lastActiveAt)}'),
          ],
        ),
        trailing: Icon(
          device.isActive ? Icons.circle : Icons.circle_outlined,
          color: device.isActive ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  IconData _getPlatformIcon() {
    switch (device.platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}