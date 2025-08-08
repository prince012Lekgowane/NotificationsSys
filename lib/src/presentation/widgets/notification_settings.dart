import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  final Map<String, dynamic>? initialSettings;
  final Function(Map<String, dynamic>)? onSettingsChanged;

  const NotificationSettings({
    Key? key,
    this.initialSettings,
    this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings =
        widget.initialSettings ??
        {
          'enabled': true,
          'sound': true,
          'vibration': true,
          'badge': true,
          'types': {
            'general': true,
            'promotion': false,
            'alert': true,
            'message': true,
          },
          'quietHours': {'enabled': false, 'startHour': 22, 'endHour': 7},
        };
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _settings[key] = value;
    });
    widget.onSettingsChanged?.call(_settings);
  }

  void _updateNestedSetting(String parentKey, String key, dynamic value) {
    setState(() {
      _settings[parentKey][key] = value;
    });
    widget.onSettingsChanged?.call(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive notifications from this app'),
          value: _settings['enabled'] ?? true,
          onChanged: (value) => _updateSetting('enabled', value),
        ),
        if (_settings['enabled'] == true) ...[
          const Divider(),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound for notifications'),
            value: _settings['sound'] ?? true,
            onChanged: (value) => _updateSetting('sound', value),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate for notifications'),
            value: _settings['vibration'] ?? true,
            onChanged: (value) => _updateSetting('vibration', value),
          ),
          SwitchListTile(
            title: const Text('Badge'),
            subtitle: const Text('Show badge count on app icon'),
            value: _settings['badge'] ?? true,
            onChanged: (value) => _updateSetting('badge', value),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ..._buildTypeSettings(),
          const Divider(),
          SwitchListTile(
            title: const Text('Quiet Hours'),
            subtitle: const Text('Silence notifications during specific hours'),
            value: _settings['quietHours']['enabled'] ?? false,
            onChanged:
                (value) => _updateNestedSetting('quietHours', 'enabled', value),
          ),
          if (_settings['quietHours']['enabled'] == true) ...[
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(
                _formatHour(_settings['quietHours']['startHour'] ?? 22),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime('startHour'),
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(
                _formatHour(_settings['quietHours']['endHour'] ?? 7),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime('endHour'),
            ),
          ],
        ],
      ],
    );
  }

  List<Widget> _buildTypeSettings() {
    final types = _settings['types'] as Map<String, dynamic>;
    return types.entries.map((entry) {
      return CheckboxListTile(
        title: Text(_getTypeDisplayName(entry.key)),
        subtitle: Text(_getTypeDescription(entry.key)),
        value: entry.value ?? false,
        onChanged: (value) => _updateNestedSetting('types', entry.key, value),
      );
    }).toList();
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'general':
        return 'General';
      case 'promotion':
        return 'Promotions';
      case 'alert':
        return 'Alerts';
      case 'message':
        return 'Messages';
      default:
        return type.toUpperCase();
    }
  }

  String _getTypeDescription(String type) {
    switch (type) {
      case 'general':
        return 'General app notifications';
      case 'promotion':
        return 'Promotional offers and deals';
      case 'alert':
        return 'Important alerts and warnings';
      case 'message':
        return 'New message notifications';
      default:
        return 'Notifications of type $type';
    }
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  Future<void> _selectTime(String timeKey) async {
    final currentHour = _settings['quietHours'][timeKey] ?? 22;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: 0),
    );

    if (time != null) {
      _updateNestedSetting('quietHours', timeKey, time.hour);
    }
  }
}
