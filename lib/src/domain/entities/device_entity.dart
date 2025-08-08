import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String fcmToken;
  final String platform;
  final String deviceName;
  final String osVersion;
  final String appVersion;
  final String appBuildNumber;
  final String? manufacturer;
  final String? model;
  final bool isActive;
  final DateTime registeredAt;
  final DateTime lastActiveAt;
  final DateTime? tokenUpdatedAt;
  final List<String> subscribedTopics;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;

  const DeviceEntity({
    required this.id,
    required this.fcmToken,
    required this.platform,
    required this.deviceName,
    required this.osVersion,
    required this.appVersion,
    required this.appBuildNumber,
    this.manufacturer,
    this.model,
    this.isActive = true,
    required this.registeredAt,
    required this.lastActiveAt,
    this.tokenUpdatedAt,
    this.subscribedTopics = const [],
    this.settings = const {},
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        fcmToken,
        platform,
        deviceName,
        osVersion,
        appVersion,
        appBuildNumber,
        manufacturer,
        model,
        isActive,
        registeredAt,
        lastActiveAt,
        tokenUpdatedAt,
        subscribedTopics,
        settings,
        metadata,
      ];

  DeviceEntity copyWith({
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
    return DeviceEntity(
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

  // Subscribe to a topic
  DeviceEntity subscribeToTopic(String topic) {
    if (subscribedTopics.contains(topic)) return this;
    
    final updatedTopics = List<String>.from(subscribedTopics)..add(topic);
    return copyWith(subscribedTopics: updatedTopics);
  }

  // Unsubscribe from a topic
  DeviceEntity unsubscribeFromTopic(String topic) {
    if (!subscribedTopics.contains(topic)) return this;
    
    final updatedTopics = List<String>.from(subscribedTopics)..remove(topic);
    return copyWith(subscribedTopics: updatedTopics);
  }

  // Update FCM token
  DeviceEntity updateToken(String newToken) {
    return copyWith(
      fcmToken: newToken,
      tokenUpdatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  // Mark device as active
  DeviceEntity markAsActive() {
    return copyWith(
      isActive: true,
      lastActiveAt: DateTime.now(),
    );
  }

  // Mark device as inactive
  DeviceEntity markAsInactive() {
    return copyWith(isActive: false);
  }

  // Update settings
  DeviceEntity updateSettings(Map<String, dynamic> newSettings) {
    final updatedSettings = Map<String, dynamic>.from(settings);
    updatedSettings.addAll(newSettings);
    return copyWith(settings: updatedSettings);
  }

  // Check if device is recently active
  bool get isRecentlyActive {
    final now = DateTime.now();
    final daysSinceLastActive = now.difference(lastActiveAt).inDays;
    return daysSinceLastActive <= 7; // Active within last 7 days
  }

  // Check if token needs refresh
  bool get needsTokenRefresh {
    if (tokenUpdatedAt == null) return true;
    
    final now = DateTime.now();
    final daysSinceTokenUpdate = now.difference(tokenUpdatedAt!).inDays;
    return daysSinceTokenUpdate >= 30; // Refresh every 30 days
  }

  // Get device age
  Duration get deviceAge {
    return DateTime.now().difference(registeredAt);
  }

  // Get days since last activity
  int get daysSinceLastActive {
    return DateTime.now().difference(lastActiveAt).inDays;
  }

  // Check if notifications are enabled for this device
  bool get notificationsEnabled {
    return settings['notificationsEnabled'] == true;
  }

  // Get notification preferences
  Map<String, dynamic> get notificationPreferences {
    return Map<String, dynamic>.from(settings['notificationPreferences'] ?? {});
  }

  // Get platform icon name
  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'android':
        return 'android';
      case 'ios':
        return 'apple';
      case 'web':
        return 'web';
      default:
        return 'device';
    }
  }

  // Get status color
  String get statusColor {
    if (!isActive) return 'grey';
    if (isRecentlyActive) return 'green';
    return 'orange';
  }

  // Get display name
  String get displayName {
    if (deviceName.isNotEmpty) return deviceName;
    if (manufacturer != null && model != null) {
      return '$manufacturer $model';
    }
    return 'Unknown Device';
  }

  // Check if device supports rich notifications
  bool get supportsRichNotifications {
    switch (platform.toLowerCase()) {
      case 'android':
        // Android 7.0 supports rich notifications
        final versionParts = osVersion.split('.');
        if (versionParts.isNotEmpty) {
          final majorVersion = int.tryParse(versionParts[0]) ?? 0;
          return majorVersion >= 7;
        }
        return false;
      case 'ios':
        // iOS 10 supports rich notifications
        final versionParts = osVersion.split('.');
        if (versionParts.isNotEmpty) {
          final majorVersion = int.tryParse(versionParts[0]) ?? 0;
          return majorVersion >= 10;
        }
        return false;
      case 'web':
        return true; // Web generally supports rich notifications
      default:
        return false;
    }
  }

  @override
  String toString() {
    return 'DeviceEntity(id: $id, platform: $platform, deviceName: $deviceName, isActive: $isActive)';
  }
}

// Device statistics for analytics
class DeviceStatistics extends Equatable {
  final int totalDevices;
  final int activeDevices;
  final int inactiveDevices;
  final Map<String, int> platformDistribution;
  final Map<String, int> osVersionDistribution;
  final Map<String, int> appVersionDistribution;
  final double activeRate;
  final DateTime lastUpdated;

  const DeviceStatistics({
    this.totalDevices = 0,
    this.activeDevices = 0,
    this.inactiveDevices = 0,
    this.platformDistribution = const {},
    this.osVersionDistribution = const {},
    this.appVersionDistribution = const {},
    this.activeRate = 0.0,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        totalDevices,
        activeDevices,
        inactiveDevices,
        platformDistribution,
        osVersionDistribution,
        appVersionDistribution,
        activeRate,
        lastUpdated,
      ];

  DeviceStatistics copyWith({
    int? totalDevices,
    int? activeDevices,
    int? inactiveDevices,
    Map<String, int>? platformDistribution,
    Map<String, int>? osVersionDistribution,
    Map<String, int>? appVersionDistribution,
    double? activeRate,
    DateTime? lastUpdated,
  }) {
    return DeviceStatistics(
      totalDevices: totalDevices ?? this.totalDevices,
      activeDevices: activeDevices ?? this.activeDevices,
      inactiveDevices: inactiveDevices ?? this.inactiveDevices,
      platformDistribution: platformDistribution ?? this.platformDistribution,
      osVersionDistribution: osVersionDistribution ?? this.osVersionDistribution,
      appVersionDistribution: appVersionDistribution ?? this.appVersionDistribution,
      activeRate: activeRate ?? this.activeRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}