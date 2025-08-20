
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
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            'General Settings',
            [
              _buildSettingsTile(
                title: 'Enable Notifications',
                subtitle: 'Allow this app to send notifications',
                icon: Icons.notifications,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              _buildSettingsTile(
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                icon: Icons.volume_up,
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: _notificationsEnabled ? (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  } : null,
                ),
              ),
              _buildSettingsTile(
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                icon: Icons.vibration,
                trailing: Switch(
                  value: _vibrationEnabled,
                  onChanged: _notificationsEnabled ? (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  } : null,
                ),
              ),
            ],
          ),
          _buildSettingsSection(
            'Quiet Hours',
            [
              _buildSettingsTile(
                title: 'Enable Quiet Hours',
                subtitle: 'Silence notifications during specific hours',
                icon: Icons.nightlight_round,
                trailing: Switch(
                  value: _quietHoursEnabled,
                  onChanged: _notificationsEnabled ? (value) {
                    setState(() {
                      _quietHoursEnabled = value;
                    });
                  } : null,
                ),
              ),
              if (_quietHoursEnabled) ...[            
                _buildSettingsTile(
                  title: 'Start Time',
                  subtitle: _startTime.format(context),
                  icon: Icons.bedtime,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Theme.of(context).primaryColor,
                              onPrimary: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _startTime) {
                      setState(() {
                        _startTime = picked;
                      });
                    }
                  },
                ),
                _buildSettingsTile(
                  title: 'End Time',
                  subtitle: _endTime.format(context),
                  icon: Icons.wb_sunny,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Theme.of(context).primaryColor,
                              onPrimary: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _endTime) {
                      setState(() {
                        _endTime = picked;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
          _buildSettingsSection(
            'Notification Types',
            [
              _buildCheckboxTile(
                title: 'General',
                subtitle: 'General app notifications',
                icon: Icons.notifications_none,
                value: true,
                onChanged: _notificationsEnabled ? (value) {} : null,
              ),
              _buildCheckboxTile(
                title: 'Messages',
                subtitle: 'New message notifications',
                icon: Icons.message_outlined,
                value: true,
                onChanged: _notificationsEnabled ? (value) {} : null,
              ),
              _buildCheckboxTile(
                title: 'Promotions',
                subtitle: 'Promotional offers and deals',
                icon: Icons.local_offer_outlined,
                value: false,
                onChanged: _notificationsEnabled ? (value) {} : null,
              ),
              _buildCheckboxTile(
                title: 'Alerts',
                subtitle: 'Important alerts and warnings',
                icon: Icons.warning_amber_outlined,
                value: true,
                onChanged: _notificationsEnabled ? (value) {} : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
}