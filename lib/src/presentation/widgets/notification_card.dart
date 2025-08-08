import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../core/utils/notification_utils.dart';
import '../../core/constants/constants.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                notification.isRead
                    ? null
                    : Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 4),
                        _buildTitle(context),
                        const SizedBox(height: 8),
                        _buildBody(context),
                        if (notification.imageUrl != null) ...[
                          const SizedBox(height: 12),
                          _buildImage(),
                        ],
                        const SizedBox(height: 12),
                        _buildFooter(context),
                      ],
                    ),
                  ),
                  _buildActions(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color color;

    switch (notification.type.toLowerCase()) {
      case NotificationConstants.typeAlert:
        iconData = Icons.warning_rounded;
        color = Colors.orange;
        break;
      case NotificationConstants.typeMessage:
        iconData = Icons.message_rounded;
        color = Colors.blue;
        break;
      case NotificationConstants.typePromotion:
        iconData = Icons.local_offer_rounded;
        color = Colors.green;
        break;
      case NotificationConstants.typeReminder:
        iconData = Icons.alarm_rounded;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildPriorityIndicator(),
              const SizedBox(width: 8),
              Text(
                _getTypeDisplayName(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    if (notification.priority == NotificationPriority.high ||
        notification.priority == NotificationPriority.max) {
      return Icon(Icons.priority_high, size: 16, color: Colors.red);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      notification.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
        color:
            notification.isRead
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Text(
      notification.body,
      style: TextStyle(
        fontSize: 14,
        color:
            notification.isRead
                ? Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7)
                : Theme.of(context).textTheme.bodyMedium?.color,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        notification.imageUrl!,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Text(
          NotificationUtils.formatTimestamp(notification.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        if (notification.deliveredAt != null) ...[
          const SizedBox(width: 12),
          Icon(Icons.check_circle, size: 12, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            'Delivered',
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
        const Spacer(),
        if (notification.deepLink != null)
          Icon(
            Icons.open_in_new,
            size: 12,
            color: Theme.of(context).primaryColor,
          ),
      ],
    );
  }

  Widget _buildActions() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder:
          (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
              ),
            if (notification.deepLink != null)
              const PopupMenuItem(
                value: 'open_link',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new),
                    SizedBox(width: 8),
                    Text('Open link'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'mark_read':
            onTap?.call();
            break;
          case 'open_link':
            // Handle deep link navigation
            break;
          case 'delete':
            onDismiss?.call();
            break;
        }
      },
    );
  }

  String _getTypeDisplayName() {
    switch (notification.type.toLowerCase()) {
      case NotificationConstants.typeAlert:
        return 'Alert';
      case NotificationConstants.typeMessage:
        return 'Message';
      case NotificationConstants.typePromotion:
        return 'Promotion';
      case NotificationConstants.typeReminder:
        return 'Reminder';
      default:
        return 'Notification';
    }
  }
}
