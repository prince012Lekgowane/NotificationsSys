import 'package:flutter/material.dart';
import 'notification_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service
  try {
    await NotificationService.instance.initialize({
      'enableLocalNotifications': true,
      'enableAnalytics': true,
    });
    print('✅ NotificationService initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize NotificationService: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification System Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Get current FCM token
    final token = await NotificationService.instance.refreshToken();
    setState(() {
      _currentToken = token;
    });

    // Listen for incoming notifications
    NotificationService.instance.notificationStream.listen((notification) {
      _showNotificationSnackBar(notification);
    });

    // Listen for token updates
    NotificationService.instance.tokenStream.listen((token) {
      setState(() {
        _currentToken = token;
      });
    });
  }

  void _showNotificationSnackBar(NotificationEntity notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(notification.body),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Handle notification tap
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification System Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOverviewTab(),
          const NotificationDashboard(),
          const DeviceManagementPage(),
          const NotificationSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Overview'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        NotificationService.instance.isInitialized
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            NotificationService.instance.isInitialized
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        NotificationService.instance.isInitialized
                            ? 'Initialized'
                            : 'Not Initialized',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FCM Token',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _currentToken ?? 'No token available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActionCard(
                'Send Test Notification',
                Icons.send,
                () => _sendTestNotification(),
              ),
              _buildActionCard(
                'Subscribe to News',
                Icons.newspaper,
                () => _subscribeToTopic('news'),
              ),
              _buildActionCard(
                'Request Permissions',
                Icons.security,
                () => _requestPermissions(),
              ),
              _buildActionCard(
                'Refresh Token',
                Icons.refresh,
                () => _refreshToken(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      await NotificationService.instance.send(
        title: 'Test Notification',
        body: 'This is a test notification from the demo app!',
        data: {
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'demo_app',
        },
        type: NotificationConstants.typeGeneral,
        priority: NotificationPriority.normal,
      );

      _showSnackBar('✅ Test notification sent successfully!');
    } catch (e) {
      _showSnackBar('❌ Failed to send notification: $e');
    }
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await NotificationService.instance.subscribeToTopic(topic);
      _showSnackBar('✅ Successfully subscribed to $topic');
    } catch (e) {
      _showSnackBar('❌ Failed to subscribe to $topic: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final granted = await NotificationService.instance.requestPermissions();
      if (granted) {
        _showSnackBar('✅ Notification permissions granted');
      } else {
        _showSnackBar('❌ Notification permissions denied');
      }
    } catch (e) {
      _showSnackBar('❌ Failed to request permissions: $e');
    }
  }

  Future<void> _refreshToken() async {
    try {
      final token = await NotificationService.instance.refreshToken();
      setState(() {
        _currentToken = token;
      });
      _showSnackBar('✅ Token refreshed successfully');
    } catch (e) {
      _showSnackBar('❌ Failed to refresh token: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
