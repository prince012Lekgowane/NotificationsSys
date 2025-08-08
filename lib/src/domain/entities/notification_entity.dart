
import 'package:equatable/equatable.dart';
import '../../core/constants/constants.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? iconUrl;
  final String type;
  final String priority;
  final String status;
  final Map<String, dynamic> data;
  final List<String> targetDevices;
  final List<String> targetTopics;
  final String? deepLink;
  final String? sound;
  final int? badge;
  final String? color;
  final String? tag;
  final String? group;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final Map<String, dynamic> analytics;
  final bool isRead;
  final bool isActionable;
  final List<NotificationAction> actions;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.iconUrl,
    required this.type,
    required this.priority,
    required this.status,
    this.data = const {},
    this.targetDevices = const [],
    this.targetTopics = const [],
    this.deepLink,
    this.sound,
    this.badge,
    this.color,
    this.tag,
    this.group,
    required this.createdAt,
    this.scheduledAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.analytics = const {},
    this.isRead = false,
    this.isActionable = false,
    this.actions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        imageUrl,
        iconUrl,
        type,
        priority,
        status,
        data,
        targetDevices,
        targetTopics,
        deepLink,
        sound,
        badge,
        color,
        tag,
        group,
        createdAt,
        scheduledAt,
        sentAt,
        deliveredAt,
        readAt,
        analytics,
        isRead,
        isActionable,
        actions,
      ];

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    String? iconUrl,
    String? type,
    String? priority,
    String? status,
    Map<String, dynamic>? data,
    List<String>? targetDevices,
    List<String>? targetTopics,
    String? deepLink,
    String? sound,
    int? badge,
    String? color,
    String? tag,
    String? group,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    Map<String, dynamic>? analytics,
    bool? isRead,
    bool? isActionable,
    List<NotificationAction>? actions,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      data: data ?? this.data,
      targetDevices: targetDevices ?? this.targetDevices,
      targetTopics: targetTopics ?? this.targetTopics,
      deepLink: deepLink ?? this.deepLink,
      sound: sound ?? this.sound,
      badge: badge ?? this.badge,
      color: color ?? this.color,
      tag: tag ?? this.tag,
      group: group ?? this.group,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      analytics: analytics ?? this.analytics,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
      actions: actions ?? this.actions,
    );
  }

  // Mark notification as read
  NotificationEntity markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
      status: NotificationStatus.read,
    );
  }

  // Check if notification is expired
  bool get isExpired {
    if (scheduledAt == null) return false;
    return DateTime.now().isAfter(scheduledAt!.add(const Duration(days: 30)));
  }

  // Check if notification is scheduled for future
  bool get isScheduled {
    if (scheduledAt == null) return false;
    return DateTime.now().isBefore(scheduledAt!);
  }

  // Get time until scheduled delivery
  Duration? get timeUntilScheduled {
    if (scheduledAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(scheduledAt!)) return null;
    return scheduledAt!.difference(now);
  }

  // Calculate delivery time
  Duration? get deliveryTime {
    if (sentAt == null || deliveredAt == null) return null;
    return deliveredAt!.difference(sentAt!);
  }

  // Check if notification has been interacted with
  bool get hasBeenInteracted {
    return isRead || analytics.containsKey('clicked') || analytics.containsKey('dismissed');
  }

  // Get notification age
  Duration get age {
    return DateTime.now().difference(createdAt);
  }

  // Check if notification supports actions
  bool get supportsActions {
    return isActionable && actions.isNotEmpty;
  }

  // Get formatted priority level
  int get priorityLevel {
    switch (priority.toLowerCase()) {
      case 'max':
        return 5;
      case 'high':
        return 4;
      case 'normal':
        return 3;
      case 'low':
        return 2;
      case 'min':
        return 1;
      default:
        return 3;
    }
  }

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, type: $type, status: $status, priority: $priority)';
  }
}

class NotificationAction extends Equatable {
  final String id;
  final String title;
  final String? icon;
  final Map<String, dynamic> data;
  final bool requiresAuth;
  final bool destructive;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.data = const {},
    this.requiresAuth = false,
    this.destructive = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        icon,
        data,
        requiresAuth,
        destructive,
      ];

  NotificationAction copyWith({
    String? id,
    String? title,
    String? icon,
    Map<String, dynamic>? data,
    bool? requiresAuth,
    bool? destructive,
  }) {
    return NotificationAction(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      data: data ?? this.data,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      destructive: destructive ?? this.destructive,
    );
  }

  @override
  String toString() {
    return 'NotificationAction(id: $id, title: $title, requiresAuth: $requiresAuth)';
  }
}

// Analytics data structure for notifications
class NotificationAnalytics extends Equatable {
  final int sentCount;
  final int deliveredCount;
  final int readCount;
  final int clickedCount;
  final int dismissedCount;
  final double deliveryRate;
  final double openRate;
  final double clickThroughRate;
  final Map<String, int> platformStats;
  final Map<String, int> deviceStats;
  final DateTime lastUpdated;

  const NotificationAnalytics({
    this.sentCount = 0,
    this.deliveredCount = 0,
    this.readCount = 0,
    this.clickedCount = 0,
    this.dismissedCount = 0,
    this.deliveryRate = 0.0,
    this.openRate = 0.0,
    this.clickThroughRate = 0.0,
    this.platformStats = const {},
    this.deviceStats = const {},
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        sentCount,
        deliveredCount,
        readCount,
        clickedCount,
        dismissedCount,
        deliveryRate,
        openRate,
        clickThroughRate,
        platformStats,
        deviceStats,
        lastUpdated,
      ];

  NotificationAnalytics copyWith({
    int? sentCount,
    int? deliveredCount,
    int? readCount,
    int? clickedCount,
    int? dismissedCount,
    double? deliveryRate,
    double? openRate,
    double? clickThroughRate,
    Map<String, int>? platformStats,
    Map<String, int>? deviceStats,
    DateTime? lastUpdated,
  }) {
    return NotificationAnalytics(
      sentCount: sentCount ?? this.sentCount,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      readCount: readCount ?? this.readCount,
      clickedCount: clickedCount ?? this.clickedCount,
      dismissedCount: dismissedCount ?? this.dismissedCount,
      deliveryRate: deliveryRate ?? this.deliveryRate,
      openRate: openRate ?? this.openRate,
      clickThroughRate: clickThroughRate ?? this.clickThroughRate,
      platformStats: platformStats ?? this.platformStats,
      deviceStats: deviceStats ?? this.deviceStats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}