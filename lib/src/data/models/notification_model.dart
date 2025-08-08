
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    super.iconUrl,
    required super.type,
    required super.priority,
    required super.status,
    super.data = const {},
    super.targetDevices = const [],
    super.targetTopics = const [],
    super.deepLink,
    super.sound,
    super.badge,
    super.color,
    super.tag,
    super.group,
    required super.createdAt,
    super.scheduledAt,
    super.sentAt,
    super.deliveredAt,
    super.readAt,
    super.analytics = const {},
    super.isRead = false,
    super.isActionable = false,
    super.actions = const [],
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      type: json['type'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      targetDevices: List<String>.from(json['targetDevices'] ?? []),
      targetTopics: List<String>.from(json['targetTopics'] ?? []),
      deepLink: json['deepLink'] as String?,
      sound: json['sound'] as String?,
      badge: json['badge'] as int?,
      color: json['color'] as String?,
      tag: json['tag'] as String?,
      group: json['group'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt'] as String) : null,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt'] as String) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      analytics: Map<String, dynamic>.from(json['analytics'] ?? {}),
      isRead: json['isRead'] as bool? ?? false,
      isActionable: json['isActionable'] as bool? ?? false,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((item) => NotificationActionModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'type': type,
      'priority': priority,
      'status': status,
      'data': data,
      'targetDevices': targetDevices,
      'targetTopics': targetTopics,
      'deepLink': deepLink,
      'sound': sound,
      'badge': badge,
      'color': color,
      'tag': tag,
      'group': group,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'analytics': analytics,
      'isRead': isRead,
      'isActionable': isActionable,
      'actions': actions.map((action) => (action as NotificationActionModel).toJson()).toList(),
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      imageUrl: entity.imageUrl,
      iconUrl: entity.iconUrl,
      type: entity.type,
      priority: entity.priority,
      status: entity.status,
      data: entity.data,
      targetDevices: entity.targetDevices,
      targetTopics: entity.targetTopics,
      deepLink: entity.deepLink,
      sound: entity.sound,
      badge: entity.badge,
      color: entity.color,
      tag: entity.tag,
      group: entity.group,
      createdAt: entity.createdAt,
      scheduledAt: entity.scheduledAt,
      sentAt: entity.sentAt,
      deliveredAt: entity.deliveredAt,
      readAt: entity.readAt,
      analytics: entity.analytics,
      isRead: entity.isRead,
      isActionable: entity.isActionable,
      actions: entity.actions.map((action) => NotificationActionModel.fromEntity(action)).toList(),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      iconUrl: iconUrl,
      type: type,
      priority: priority,
      status: status,
      data: data,
      targetDevices: targetDevices,
      targetTopics: targetTopics,
      deepLink: deepLink,
      sound: sound,
      badge: badge,
      color: color,
      tag: tag,
      group: group,
      createdAt: createdAt,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      deliveredAt: deliveredAt,
      readAt: readAt,
      analytics: analytics,
      isRead: isRead,
      isActionable: isActionable,
      actions: actions.map((action) => (action as NotificationActionModel).toEntity()).toList(),
    );
  }

  @override
  NotificationModel copyWith({
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
    return NotificationModel(
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
}

class NotificationActionModel extends NotificationAction {
  const NotificationActionModel({
    required super.id,
    required super.title,
    super.icon,
    super.data = const {},
    super.requiresAuth = false,
    super.destructive = false,
  });

  factory NotificationActionModel.fromJson(Map<String, dynamic> json) {
    return NotificationActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      requiresAuth: json['requiresAuth'] as bool? ?? false,
      destructive: json['destructive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'data': data,
      'requiresAuth': requiresAuth,
      'destructive': destructive,
    };
  }

  factory NotificationActionModel.fromEntity(NotificationAction entity) {
    return NotificationActionModel(
      id: entity.id,
      title: entity.title,
      icon: entity.icon,
      data: entity.data,
      requiresAuth: entity.requiresAuth,
      destructive: entity.destructive,
    );
  }

  NotificationAction toEntity() {
    return NotificationAction(
      id: id,
      title: title,
      icon: icon,
      data: data,
      requiresAuth: requiresAuth,
      destructive: destructive,
    );
  }
}