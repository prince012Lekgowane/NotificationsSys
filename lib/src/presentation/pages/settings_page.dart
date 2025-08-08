
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Allow this app to send notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound for notifications'),
            value: _soundEnabled,
            onChanged: _notificationsEnabled ? (value) {
              setState(() {
                _soundEnabled = value;
              });
            } : null,
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate for notifications'),
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled ? (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            } : null,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Quiet Hours'),
            subtitle: const Text('Silence notifications during quiet hours'),
            value: _quietHoursEnabled,
            onChanged: _notificationsEnabled ? (value) {
              setState(() {
                _quietHoursEnabled = value;
              });
            } : null,
          ),
          if (_quietHoursEnabled) ...[
            ListTile(
              title: const Text('Start Time'),
              subtitle: const Text('10:00 PM'),
              trailing: const Icon(Icons.access_time),
              onTap: () {
                // Show time picker
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: const Text('7:00 AM'),
              trailing: const Icon(Icons.access_time),
              onTap: () {
                // Show time picker
              },
            ),
          ],
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CheckboxListTile(
            title: const Text('General'),
            subtitle: const Text('General app notifications'),
            value: true,
            onChanged: _notificationsEnabled ? (value) {} : null,
          ),
          CheckboxListTile(
            title: const Text('Messages'),
            subtitle: const Text('New message notifications'),
            value: true,
            onChanged: _notificationsEnabled ? (value) {} : null,
          ),
          CheckboxListTile(
            title: const Text('Promotions'),
            subtitle: const Text('Promotional offers and deals'),
            value: false,
            onChanged: _notificationsEnabled ? (value) {} : null,
          ),
          CheckboxListTile(
            title: const Text('Alerts'),
            subtitle: const Text('Important alerts and warnings'),
            value: true,
            onChanged: _notificationsEnabled ? (value) {} : null,
          ),
        ],
      ),
    );
  }
}