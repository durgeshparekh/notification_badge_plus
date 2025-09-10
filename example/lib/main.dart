import 'package:flutter/material.dart';
import 'package:notification_badge_plus/notification_badge_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Badge Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Notification Badge Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _badgeCount = 0;
  bool _isSupported = false;
  String _manufacturer = '';
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlugin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh badge count
      _refreshBadgeCount();
    }
  }

  Future<void> _initializePlugin() async {
    try {
      final isSupported = await NotificationBadgePlus.isSupported();
      final manufacturer = await NotificationBadgePlus.getDeviceManufacturer();
      final currentCount = await NotificationBadgePlus.getBadgeCount();

      setState(() {
        _isSupported = isSupported;
        _manufacturer = manufacturer;
        _badgeCount = currentCount;
        _status = isSupported 
          ? 'Badge support: Available' 
          : 'Badge support: Not available';
      });
    } catch (e) {
      setState(() {
        _status = 'Error initializing: $e';
      });
    }
  }

  Future<void> _refreshBadgeCount() async {
    try {
      final currentCount = await NotificationBadgePlus.getBadgeCount();
      setState(() {
        _badgeCount = currentCount;
      });
    } catch (e) {
      setState(() {
        _status = 'Error refreshing count: $e';
      });
    }
  }

  Future<void> _setBadgeCount(int count) async {
    try {
      final success = await NotificationBadgePlus.setBadgeCount(count);
      setState(() {
        if (success) {
          _badgeCount = count;
          _status = 'Badge count set to $count';
        } else {
          _status = 'Failed to set badge count';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error setting badge count: $e';
      });
    }
  }

  Future<void> _incrementBadge() async {
    try {
      final newCount = await NotificationBadgePlus.incrementBadge();
      setState(() {
        _badgeCount = newCount;
        _status = 'Badge incremented to $newCount';
      });
    } catch (e) {
      setState(() {
        _status = 'Error incrementing badge: $e';
      });
    }
  }

  Future<void> _decrementBadge() async {
    try {
      final newCount = await NotificationBadgePlus.decrementBadge();
      setState(() {
        _badgeCount = newCount;
        _status = 'Badge decremented to $newCount';
      });
    } catch (e) {
      setState(() {
        _status = 'Error decrementing badge: $e';
      });
    }
  }

  Future<void> _clearBadge() async {
    try {
      final success = await NotificationBadgePlus.clearBadge();
      setState(() {
        if (success) {
          _badgeCount = 0;
          _status = 'Badge cleared';
        } else {
          _status = 'Failed to clear badge';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error clearing badge: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Device Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Manufacturer: $_manufacturer'),
                    Text('Badge Support: ${_isSupported ? "Yes" : "No"}'),
                    Text('Status: $_status'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Badge Count',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_badgeCount',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _isSupported ? () => _setBadgeCount(1) : null,
                  child: const Text('Set 1'),
                ),
                ElevatedButton(
                  onPressed: _isSupported ? () => _setBadgeCount(5) : null,
                  child: const Text('Set 5'),
                ),
                ElevatedButton(
                  onPressed: _isSupported ? () => _setBadgeCount(10) : null,
                  child: const Text('Set 10'),
                ),
                ElevatedButton(
                  onPressed: _isSupported ? _incrementBadge : null,
                  child: const Text('+1'),
                ),
                ElevatedButton(
                  onPressed: _isSupported ? _decrementBadge : null,
                  child: const Text('-1'),
                ),
                ElevatedButton(
                  onPressed: _isSupported ? _clearBadge : null,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshBadgeCount,
              child: const Text('Refresh Count'),
            ),
          ],
        ),
      ),
    );
  }
}