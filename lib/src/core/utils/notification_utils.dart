import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform/platform.dart';
import 'package:intl/intl.dart';
import '../constants/constants.dart';

class NotificationUtils {
  static const Platform _platform = LocalPlatform();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Generate a unique notification ID
  static int generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  /// Generate a random string for unique identifiers
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Validate notification data
  static bool isValidNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) return false;

    // Check required fields
    if (!data.containsKey('title') ||
        data['title']?.toString().trim().isEmpty == true) {
      return false;
    }

    if (!data.containsKey('body') ||
        data['body']?.toString().trim().isEmpty == true) {
      return false;
    }

    return true;
  }

  /// Validate topic name according to FCM rules
  static bool isValidTopicName(String topic) {
    if (topic.isEmpty || topic.length > 900) return false;

    // Topic name should match the regular expression [a-zA-Z0-9-_.~%]
    final regex = RegExp(r'^[a-zA-Z0-9\-_.~%]$');
    return regex.hasMatch(topic);
  }

  /// Get current platform type
  static String getCurrentPlatform() {
    if (_platform.isAndroid) return DeviceType.android;
    if (_platform.isIOS) return DeviceType.ios;
    if (_platform.isMacOS || _platform.isWindows || _platform.isLinux)
      return DeviceType.web;
    return 'unknown';
  }

  /// Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    try {
      if (_platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': DeviceType.android,
          'deviceId': androidInfo.id,
          'deviceName': '${androidInfo.brand} ${androidInfo.model}',
          'osVersion': androidInfo.version.release,
          'appVersion': packageInfo.version,
          'appBuildNumber': packageInfo.buildNumber,
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'fingerprint': androidInfo.fingerprint,
        };
      } else if (_platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': DeviceType.ios,
          'deviceId': iosInfo.identifierForVendor ?? 'unknown',
          'deviceName': iosInfo.name,
          'osVersion': iosInfo.systemVersion,
          'appVersion': packageInfo.version,
          'appBuildNumber': packageInfo.buildNumber,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
        };
      } else {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'platform': DeviceType.web,
          'deviceId': generateRandomString(32),
          'deviceName': '${webInfo.browserName} on ${webInfo.platform}',
          'osVersion': webInfo.platform ?? 'unknown',
          'appVersion': packageInfo.version,
          'appBuildNumber': packageInfo.buildNumber,
          'browserName': webInfo.browserName,
          'userAgent': webInfo.userAgent,
        };
      }
    } catch (e) {
      return {
        'platform': getCurrentPlatform(),
        'deviceId': generateRandomString(32),
        'deviceName': 'Unknown Device',
        'osVersion': 'unknown',
        'appVersion': packageInfo.version,
        'appBuildNumber': packageInfo.buildNumber,
        'error': e.toString(),
      };
    }
  }

  /// Format notification timestamp
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get appropriate notification channel based on type
  static String getNotificationChannel(String type) {
    switch (type.toLowerCase()) {
      case NotificationConstants.typeAlert:
        return NotificationConstants.highPriorityChannelId;
      case NotificationConstants.typePromotion:
        return NotificationConstants.promotionalChannelId;
      default:
        return NotificationConstants.defaultChannelId;
    }
  }

  /// Extract deep link from notification data
  static String? extractDeepLink(Map<String, dynamic> data) {
    // Check various possible keys for deep links
    final possibleKeys = [
      'click_action',
      'deep_link',
      'url',
      'route',
      'screen',
    ];

    for (final key in possibleKeys) {
      if (data.containsKey(key) && data[key]?.toString().isNotEmpty == true) {
        return data[key].toString();
      }
    }

    return null;
  }

  /// Sanitize notification content
  static Map<String, dynamic> sanitizeNotificationData(
    Map<String, dynamic> data,
  ) {
    final sanitized = <String, dynamic>{};

    // Only include safe keys and sanitize values
    final allowedKeys = [
      'title',
      'body',
      'type',
      'priority',
      'sound',
      'badge',
      'click_action',
      'deep_link',
      'url',
      'route',
      'screen',
      'image',
      'icon',
      'color',
      'tag',
      'group',
    ];

    for (final key in allowedKeys) {
      if (data.containsKey(key)) {
        final value = data[key];
        if (value != null) {
          // Basic sanitization - remove potential script tags and harmful content
          if (value is String) {
            sanitized[key] =
                value
                    .replaceAll(
                      RegExp(
                        r'<script[^>]*>.*?</script>',
                        caseSensitive: false,
                      ),
                      '',
                    )
                    .replaceAll(
                      RegExp(r'javascript:', caseSensitive: false),
                      '',
                    )
                    .trim();
          } else {
            sanitized[key] = value;
          }
        }
      }
    }

    return sanitized;
  }

  /// Calculate notification priority score for sorting
  static int getNotificationPriorityScore(String priority) {
    switch (priority.toLowerCase()) {
      case NotificationPriority.max:
        return 5;
      case NotificationPriority.high:
        return 4;
      case NotificationPriority.normal:
        return 3;
      case NotificationPriority.low:
        return 2;
      case NotificationPriority.min:
        return 1;
      default:
        return 3;
    }
  }

  /// Check if notification should be shown based on user settings
  static bool shouldShowNotification(
    Map<String, dynamic> notificationData,
    Map<String, dynamic> userSettings,
  ) {
    // Check if notifications are globally enabled
    if (userSettings['enabled'] == false) return false;

    // Check type-specific settings
    final type = notificationData['type']?.toString().toLowerCase();
    if (type != null && userSettings['types'] is Map) {
      final typeSettings = userSettings['types'] as Map;
      if (typeSettings[type] == false) return false;
    }

    // Check quiet hours
    if (userSettings['quietHours'] is Map) {
      final quietHours = userSettings['quietHours'] as Map;
      if (quietHours['enabled'] == true) {
        final now = DateTime.now();
        final startHour = quietHours['startHour'] as int? ?? 22;
        final endHour = quietHours['endHour'] as int? ?? 7;

        if (startHour > endHour) {
          // Quiet hours span midnight
          if (now.hour >= startHour || now.hour < endHour) {
            return false;
          }
        } else {
          // Normal quiet hours
          if (now.hour >= startHour && now.hour < endHour) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Convert bytes to human readable format
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Validate notification payload size
  static bool isValidPayloadSize(Map<String, dynamic> data) {
    // FCM has a limit of 4KB for the data payload
    const maxSizeBytes = 4 * 1024; // 4KB

    try {
      final jsonString = data.toString();
      final sizeBytes = jsonString.length;
      return sizeBytes <= maxSizeBytes;
    } catch (e) {
      return false;
    }
  }

  /// Create error notification data
  static Map<String, dynamic> createErrorNotification(String error) {
    return {
      'title': 'Notification Error',
      'body': error,
      'type': NotificationConstants.typeAlert,
      'priority': NotificationPriority.high,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
