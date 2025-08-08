import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.fcmToken,
    required super.platform,
    required super.deviceName,
    required super.osVersion,
    required super.appVersion,
    required super.appBuildNumber,
    super.manufacturer,
    super.model,
    super.isActive = true,
    required super.registeredAt,
    required super.lastActiveAt,
    super.tokenUpdatedAt,
    super.subscribedTopics = const [],
    super.settings = const {},
    super.metadata = const {},
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      fcmToken: json['fcmToken'] as String,
      platform: json['platform'] as String,
      deviceName: json['deviceName'] as String,
      osVersion: json['osVersion'] as String,
      appVersion: json['appVersion'] as String,
      appBuildNumber: json['appBuildNumber'] as String,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      tokenUpdatedAt:
          json['tokenUpdatedAt'] != null
              ? DateTime.parse(json['tokenUpdatedAt'] as String)
              : null,
      subscribedTopics: List<String>.from(json['subscribedTopics'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fcmToken': fcmToken,
      'platform': platform,
      'deviceName': deviceName,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'manufacturer': manufacturer,
      'model': model,
      'isActive': isActive,
      'registeredAt': registeredAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'tokenUpdatedAt': tokenUpdatedAt?.toIso8601String(),
      'subscribedTopics': subscribedTopics,
      'settings': settings,
      'metadata': metadata,
    };
  }

  factory DeviceModel.fromEntity(DeviceEntity entity) {
    return DeviceModel(
      id: entity.id,
      fcmToken: entity.fcmToken,
      platform: entity.platform,
      deviceName: entity.deviceName,
      osVersion: entity.osVersion,
      appVersion: entity.appVersion,
      appBuildNumber: entity.appBuildNumber,
      manufacturer: entity.manufacturer,
      model: entity.model,
      isActive: entity.isActive,
      registeredAt: entity.registeredAt,
      lastActiveAt: entity.lastActiveAt,
      tokenUpdatedAt: entity.tokenUpdatedAt,
      subscribedTopics: entity.subscribedTopics,
      settings: entity.settings,
      metadata: entity.metadata,
    );
  }

  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id,
      fcmToken: fcmToken,
      platform: platform,
      deviceName: deviceName,
      osVersion: osVersion,
      appVersion: appVersion,
      appBuildNumber: appBuildNumber,
      manufacturer: manufacturer,
      model: model,
      isActive: isActive,
      registeredAt: registeredAt,
      lastActiveAt: lastActiveAt,
      tokenUpdatedAt: tokenUpdatedAt,
      subscribedTopics: subscribedTopics,
      settings: settings,
      metadata: metadata,
    );
  }

  @override
  DeviceModel copyWith({
    String? id,
    String? fcmToken,
    String? platform,
    String? deviceName,
    String? osVersion,
    String? appVersion,
    String? appBuildNumber,
    String? manufacturer,
    String? model,
    bool? isActive,
    DateTime? registeredAt,
    DateTime? lastActiveAt,
    DateTime? tokenUpdatedAt,
    List<String>? subscribedTopics,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? metadata,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      fcmToken: fcmToken ?? this.fcmToken,
      platform: platform ?? this.platform,
      deviceName: deviceName ?? this.deviceName,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      isActive: isActive ?? this.isActive,
      registeredAt: registeredAt ?? this.registeredAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      tokenUpdatedAt: tokenUpdatedAt ?? this.tokenUpdatedAt,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
    );
  }
}
