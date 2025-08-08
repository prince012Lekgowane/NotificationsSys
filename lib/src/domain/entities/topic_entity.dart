import 'package:equatable/equatable.dart';

class TopicEntity extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String category;
  final bool isActive;
  final bool isPublic;
  final int subscriberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const TopicEntity({
    required this.id,
    required this.name,
    required this.displayName,
    this.description = '',
    this.category = 'general',
    this.isActive = true,
    this.isPublic = true,
    this.subscriberCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.settings = const {},
    this.tags = const [],
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        category,
        isActive,
        isPublic,
        subscriberCount,
        createdAt,
        updatedAt,
        settings,
        tags,
        metadata,
      ];

  TopicEntity copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? category,
    bool? isActive,
    bool? isPublic,
    int? subscriberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return TopicEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  // Increment subscriber count
  TopicEntity incrementSubscriberCount() {
    return copyWith(
      subscriberCount: subscriberCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  // Decrement subscriber count
  TopicEntity decrementSubscriberCount() {
    return copyWith(
      subscriberCount: subscriberCount > 0 ? subscriberCount - 1 : 0,
      updatedAt: DateTime.now(),
    );
  }

  // Update settings
  TopicEntity updateSettings(Map<String, dynamic> newSettings) {
    final updatedSettings = Map<String, dynamic>.from(settings);
    updatedSettings.addAll(newSettings);
    return copyWith(
      settings: updatedSettings,
      updatedAt: DateTime.now(),
    );
  }

  // Add tag
  TopicEntity addTag(String tag) {
    if (tags.contains(tag)) return this;

    final updatedTags = List<String>.from(tags)..add(tag);
    return copyWith(
      tags: updatedTags,
      updatedAt: DateTime.now(),
    );
  }

  // Remove tag
  TopicEntity removeTag(String tag) {
    if (!tags.contains(tag)) return this;

    final updatedTags = List<String>.from(tags)..remove(tag);
    return copyWith(
      tags: updatedTags,
      updatedAt: DateTime.now(),
    );
  }

  // Activate topic
  TopicEntity activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  // Deactivate topic
  TopicEntity deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  // Make topic public
  TopicEntity makePublic() {
    return copyWith(
      isPublic: true,
      updatedAt: DateTime.now(),
    );
  }

  // Make topic private
  TopicEntity makePrivate() {
    return copyWith(
      isPublic: false,
      updatedAt: DateTime.now(),
    );
  }

  // Check if topic allows notifications
  bool get allowsNotifications {
    return isActive && (settings['allowNotifications'] ?? true);
  }

  // Get notification frequency setting
  String get notificationFrequency {
    return settings['notificationFrequency'] ?? 'immediate';
  }

  // Check if topic has rate limiting
  bool get hasRateLimit {
    return settings['rateLimit'] != null;
  }

  // Get rate limit settings
  Map<String, dynamic> get rateLimitSettings {
    return Map<String, dynamic>.from(settings['rateLimit'] ?? {});
  }

  // Get topic priority
  int get priority {
    return settings['priority'] ?? 3; // Default normal priority
  }

  // Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'news':
        return 'news';
      case 'promotions':
        return 'local_offer';
      case 'alerts':
        return 'warning';
      case 'updates':
        return 'system_update';
      case 'social':
        return 'people';
      case 'sports':
        return 'sports';
      case 'weather':
        return 'wb_sunny';
      case 'finance':
        return 'account_balance';
      default:
        return 'topic';
    }
  }

  // Get category color
  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'news':
        return 'blue';
      case 'promotions':
        return 'green';
      case 'alerts':
        return 'red';
      case 'updates':
        return 'orange';
      case 'social':
        return 'purple';
      case 'sports':
        return 'indigo';
      case 'weather':
        return 'yellow';
      case 'finance':
        return 'teal';
      default:
        return 'grey';
    }
  }

  // Check if topic is popular
  bool get isPopular {
    return subscriberCount >= 1000;
  }

  // Check if topic is trending
  bool get isTrending {
    // Calculate if subscriber count increased significantly in recent time
    final recentGrowth = metadata['recentGrowth'] as int? ?? 0;
    return recentGrowth > 50; // More than 50 new subscribers recently
  }

  // Get subscription growth rate
  double get growthRate {
    final initialCount =
        metadata['initialSubscriberCount'] as int? ?? subscriberCount;
    if (initialCount == 0) return 0.0;

    return ((subscriberCount - initialCount) / initialCount) * 100;
  }

  // Get topic age
  Duration get age {
    return DateTime.now().difference(createdAt);
  }

  // Get days since last update
  int get daysSinceLastUpdate {
    return DateTime.now().difference(updatedAt).inDays;
  }

  // Check if topic needs attention (no recent activity)
  bool get needsAttention {
    return daysSinceLastUpdate > 30 && subscriberCount < 10;
  }

  @override
  String toString() {
    return 'TopicEntity(id: $id, name: $name, displayName: $displayName, subscriberCount: $subscriberCount)';
  }
}

// Topic subscription entity
class TopicSubscription extends Equatable {
  final String id;
  final String topicId;
  final String deviceId;
  final DateTime subscribedAt;
  final bool isActive;
  final Map<String, dynamic> preferences;

  const TopicSubscription({
    required this.id,
    required this.topicId,
    required this.deviceId,
    required this.subscribedAt,
    this.isActive = true,
    this.preferences = const {},
  });

  @override
  List<Object?> get props => [
        id,
        topicId,
        deviceId,
        subscribedAt,
        isActive,
        preferences,
      ];

  TopicSubscription copyWith({
    String? id,
    String? topicId,
    String? deviceId,
    DateTime? subscribedAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return TopicSubscription(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      deviceId: deviceId ?? this.deviceId,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }

  // Activate subscription
  TopicSubscription activate() {
    return copyWith(isActive: true);
  }

  // Deactivate subscription
  TopicSubscription deactivate() {
    return copyWith(isActive: false);
  }

  // Update preferences
  TopicSubscription updatePreferences(Map<String, dynamic> newPreferences) {
    final updatedPreferences = Map<String, dynamic>.from(preferences);
    updatedPreferences.addAll(newPreferences);
    return copyWith(preferences: updatedPreferences);
  }

  // Get subscription duration
  Duration get subscriptionDuration {
    return DateTime.now().difference(subscribedAt);
  }

  @override
  String toString() {
    return 'TopicSubscription(id: $id, topicId: $topicId, deviceId: $deviceId, isActive: $isActive)';
  }
}

// Topic analytics
class TopicAnalytics extends Equatable {
  final String topicId;
  final int totalSubscribers;
  final int activeSubscribers;
  final int notificationsSent;
  final int notificationsDelivered;
  final int notificationsRead;
  final double engagementRate;
  final double unsubscribeRate;
  final Map<String, int> platformDistribution;
  final Map<String, int> dailyActivity;
  final DateTime lastUpdated;

  const TopicAnalytics({
    required this.topicId,
    this.totalSubscribers = 0,
    this.activeSubscribers = 0,
    this.notificationsSent = 0,
    this.notificationsDelivered = 0,
    this.notificationsRead = 0,
    this.engagementRate = 0.0,
    this.unsubscribeRate = 0.0,
    this.platformDistribution = const {},
    this.dailyActivity = const {},
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        topicId,
        totalSubscribers,
        activeSubscribers,
        notificationsSent,
        notificationsDelivered,
        notificationsRead,
        engagementRate,
        unsubscribeRate,
        platformDistribution,
        dailyActivity,
        lastUpdated,
      ];

  TopicAnalytics copyWith({
    String? topicId,
    int? totalSubscribers,
    int? activeSubscribers,
    int? notificationsSent,
    int? notificationsDelivered,
    int? notificationsRead,
    double? engagementRate,
    double? unsubscribeRate,
    Map<String, int>? platformDistribution,
    Map<String, int>? dailyActivity,
    DateTime? lastUpdated,
  }) {
    return TopicAnalytics(
      topicId: topicId ?? this.topicId,
      totalSubscribers: totalSubscribers ?? this.totalSubscribers,
      activeSubscribers: activeSubscribers ?? this.activeSubscribers,
      notificationsSent: notificationsSent ?? this.notificationsSent,
      notificationsDelivered:
          notificationsDelivered ?? this.notificationsDelivered,
      notificationsRead: notificationsRead ?? this.notificationsRead,
      engagementRate: engagementRate ?? this.engagementRate,
      unsubscribeRate: unsubscribeRate ?? this.unsubscribeRate,
      platformDistribution: platformDistribution ?? this.platformDistribution,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
