# Background and Foreground Notification Badge Handling

This guide provides comprehensive information on how the notification_badge_plus plugin handles badge counts in both foreground and background app states across iOS and Android platforms.

## Table of Contents
- [Overview](#overview)
- [iOS Background/Foreground Handling](#ios-backgroundforeground-handling)
- [Android Background/Foreground Handling](#android-backgroundforeground-handling)
- [Implementation Examples](#implementation-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The notification_badge_plus plugin automatically manages badge counts across different app states:

- **Foreground**: When the app is active and visible to the user
- **Background**: When the app is not visible but still running in memory
- **Terminated**: When the app is completely closed by the system

### Key Features
- ✅ Automatic badge persistence across app state changes
- ✅ Badge count synchronization when returning to foreground
- ✅ Background badge updates (iOS native, Android via notifications)
- ✅ System-level badge integration
- ✅ Cross-platform consistent behavior

## iOS Background/Foreground Handling

### Native iOS Badge Management

iOS provides native support for app icon badges through the system. The plugin leverages this functionality:

```swift
// iOS 16+ Method
UNUserNotificationCenter.current().setBadgeCount(count)

// Legacy iOS Method (9.0 - 15.x)
UIApplication.shared.applicationIconBadgeNumber = count
```

### Automatic Lifecycle Management

The iOS implementation automatically handles app lifecycle events:

#### App Lifecycle Events Handled:
1. **`didBecomeActive`** - App comes to foreground
2. **`didEnterBackground`** - App goes to background
3. **`willTerminate`** - App is about to terminate

#### iOS Implementation Details:

```swift
@objc private func applicationDidBecomeActive() {
    // Sync badge count when app becomes active
    if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().getBadgeCount { count in
            self.currentBadgeCount = Int(count)
        }
    } else {
        self.currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
    }
}

@objc private func applicationDidEnterBackground() {
    // Preserve badge count when app enters background
    if currentBadgeCount > 0 {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(self.currentBadgeCount)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = self.currentBadgeCount
        }
    }
}
```

### iOS Badge Persistence

- **System Level**: Badge counts persist at the iOS system level
- **App Restart**: Badge counts are maintained even after app termination
- **Device Reboot**: Badge counts persist through device restarts
- **App Updates**: Badge counts are preserved during app updates

### iOS Background Badge Updates

iOS allows badge updates while the app is in the background:

```dart
// This works even when app is in background
await NotificationBadgePlus.setBadgeCount(5);
```

**Requirements for Background Updates:**
- App must have notification permissions
- Badge updates work immediately without user interaction
- No additional background modes required

## Android Background/Foreground Handling

### Android Badge Complexity

Android badge handling is more complex due to manufacturer variations:

#### Manufacturer-Specific Behavior:

**Samsung Devices:**
```kotlin
// Uses ContentResolver - works in background
val contentValues = ContentValues().apply {
    put("package", context.packageName)
    put("badgecount", count)
}
context.contentResolver.insert(uri, contentValues)
```

**Xiaomi Devices:**
```kotlin
// Launcher broadcast + MIUI content-provider fallback (no synthetic notifications)
val intent = Intent("android.intent.action.APPLICATION_MESSAGE_UPDATE").apply {
    putExtra(
        "android.intent.extra.update_application_component_name",
        "${packageName}/${launcherActivityClass}"
    )
    putExtra(
        "android.intent.extra.update_application_message_text",
        if (count <= 0) "" else count.toString()
    )
}
context.sendBroadcast(intent)
```

**Other Manufacturers:**
```kotlin
// Broadcast-based approaches
val intent = Intent("com.manufacturer.launcher.action.UPDATE_BADGE")
context.sendBroadcast(intent)
```

### Android Badge Persistence

The plugin uses SharedPreferences to maintain badge counts:

```kotlin
// Store badge count for persistence
prefs.edit().putInt("badge_count", count).apply()

// Retrieve badge count on app restart
fun getBadgeCount(): Int {
    return prefs.getInt("badge_count", 0)
}
```

### Android Background Limitations

**Notification-Based Badges (Xiaomi, etc.):**
- Require active notification to show badge
- Background app restrictions may affect updates
- Android 12+ may limit background notifications

**ContentResolver-Based Badges (Samsung):**
- Work reliably in background
- No additional restrictions

**Broadcast-Based Badges (OPPO, Vivo, etc.):**
- May be limited by background app restrictions
- Android 8.0+ has broadcast limitations

## Implementation Examples

### Basic Foreground/Background Handling

```dart
import 'package:flutter/material.dart';
import 'package:notification_badge_plus/notification_badge_plus.dart';

class BadgeManager extends StatefulWidget {
  @override
  _BadgeManagerState createState() => _BadgeManagerState();
}

class _BadgeManagerState extends State<BadgeManager> 
    with WidgetsBindingObserver {
  int _badgeCount = 0;

  @override
  void initState() {
    super.initState();
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    _initializeBadge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        _syncBadgeFromSystem();
        break;
      case AppLifecycleState.paused:
        // App going to background
        _saveBadgeState();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _saveBadgeState();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (transition state)
        break;
      case AppLifecycleState.hidden:
        // App window is hidden
        break;
    }
  }

  Future<void> _initializeBadge() async {
    try {
      final count = await NotificationBadgePlus.getBadgeCount();
      setState(() {
        _badgeCount = count;
      });
    } catch (e) {
      print('Error initializing badge: $e');
    }
  }

  Future<void> _syncBadgeFromSystem() async {
    try {
      final systemBadgeCount = await NotificationBadgePlus.getBadgeCount();
      if (systemBadgeCount != _badgeCount) {
        setState(() {
          _badgeCount = systemBadgeCount;
        });
        print('Badge synced from system: $_badgeCount');
      }
    } catch (e) {
      print('Error syncing badge from system: $e');
    }
  }

  Future<void> _saveBadgeState() async {
    try {
      // Ensure badge is persisted
      await NotificationBadgePlus.setBadgeCount(_badgeCount);
      print('Badge state saved: $_badgeCount');
    } catch (e) {
      print('Error saving badge state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Badge Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Badge Count: $_badgeCount'),
            ElevatedButton(
              onPressed: () => _updateBadge(_badgeCount + 1),
              child: Text('Increment Badge'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBadge(int newCount) async {
    try {
      final success = await NotificationBadgePlus.setBadgeCount(newCount);
      if (success) {
        setState(() {
          _badgeCount = newCount;
        });
      }
    } catch (e) {
      print('Error updating badge: $e');
    }
  }
}
```

### Advanced Background Badge Management

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notification_badge_plus/notification_badge_plus.dart';

class AdvancedBadgeManager {
  static Timer? _backgroundTimer;
  static int _pendingBadgeCount = 0;

  /// Initialize badge management system
  static Future<void> initialize() async {
    // Restore badge count on app start
    await _restoreBadgeCount();
    
    // Set up periodic background sync (if needed)
    _setupBackgroundSync();
  }

  /// Handle incoming notifications while app is in background
  static Future<void> handleBackgroundNotification({
    required int increment = 1,
  }) async {
    try {
      final currentCount = await NotificationBadgePlus.getBadgeCount();
      final newCount = currentCount + increment;
      
      final success = await NotificationBadgePlus.setBadgeCount(newCount);
      if (success) {
        print('Background badge updated: $newCount');
      }
    } catch (e) {
      print('Error handling background notification: $e');
    }
  }

  /// Sync badge when app returns to foreground
  static Future<void> syncOnForeground() async {
    try {
      // Get current system badge count
      final systemCount = await NotificationBadgePlus.getBadgeCount();
      
      // Apply any pending updates
      if (_pendingBadgeCount > 0) {
        final newCount = systemCount + _pendingBadgeCount;
        await NotificationBadgePlus.setBadgeCount(newCount);
        _pendingBadgeCount = 0;
        print('Applied pending badge updates: $newCount');
      }
    } catch (e) {
      print('Error syncing on foreground: $e');
    }
  }

  /// Queue badge updates for when app returns to foreground
  static void queueBadgeUpdate(int count) {
    _pendingBadgeCount += count;
    print('Queued badge update: $count (total pending: $_pendingBadgeCount)');
  }

  static Future<void> _restoreBadgeCount() async {
    try {
      final count = await NotificationBadgePlus.getBadgeCount();
      print('Restored badge count: $count');
    } catch (e) {
      print('Error restoring badge count: $e');
    }
  }

  static void _setupBackgroundSync() {
    // Optional: Set up periodic sync for Android devices
    // that might need badge refresh
    _backgroundTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      try {
        final count = await NotificationBadgePlus.getBadgeCount();
        // Re-apply badge count to ensure visibility
        await NotificationBadgePlus.setBadgeCount(count);
      } catch (e) {
        print('Background sync error: $e');
      }
    });
  }

  static void dispose() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }
}
```

### Push Notification Integration

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notification_badge_plus/notification_badge_plus.dart';

class PushNotificationBadgeHandler {
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Handle background push notifications
    final badgeIncrement = _extractBadgeCount(message);
    if (badgeIncrement > 0) {
      await AdvancedBadgeManager.handleBackgroundNotification(
        increment: badgeIncrement,
      );
    }
  }

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    // Handle foreground push notifications
    final badgeIncrement = _extractBadgeCount(message);
    if (badgeIncrement > 0) {
      final currentCount = await NotificationBadgePlus.getBadgeCount();
      await NotificationBadgePlus.setBadgeCount(currentCount + badgeIncrement);
    }
  }

  static int _extractBadgeCount(RemoteMessage message) {
    // Extract badge count from push notification payload
    final data = message.data;
    if (data.containsKey('badge')) {
      return int.tryParse(data['badge'].toString()) ?? 0;
    }
    return 1; // Default increment
  }
}

// Usage in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize badge management
  await AdvancedBadgeManager.initialize();
  
  // Set up push notification handlers
  FirebaseMessaging.onBackgroundMessage(
    PushNotificationBadgeHandler.handleBackgroundMessage,
  );
  
  FirebaseMessaging.onMessage.listen(
    PushNotificationBadgeHandler.handleForegroundMessage,
  );
  
  runApp(MyApp());
}
```

## Best Practices

### 1. App Lifecycle Management
```dart
// Always register for lifecycle events
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeBadgeSystem();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

### 2. Error Handling
```dart
Future<void> updateBadgeWithFallback(int count) async {
  try {
    final success = await NotificationBadgePlus.setBadgeCount(count);
    if (!success) {
      // Fallback for unsupported devices
      print('Badge not supported on this device');
      _showInAppNotificationIndicator(count);
    }
  } catch (e) {
    // Handle errors gracefully
    print('Badge update error: $e');
    _showInAppNotificationIndicator(count);
  }
}
```

### 3. Platform-Specific Handling
```dart
import 'dart:io';

Future<void> platformSpecificBadgeHandling(int count) async {
  if (Platform.isIOS) {
    // iOS: Badge updates work reliably in background
    await NotificationBadgePlus.setBadgeCount(count);
  } else if (Platform.isAndroid) {
    await NotificationBadgePlus.setBadgeCount(count);
  }
}
```

### 4. Badge Synchronization
```dart
Future<void> syncBadgeOnAppResume() async {
  try {
    // Get badge count from system
    final systemBadgeCount = await NotificationBadgePlus.getBadgeCount();
    
    // Get your app's internal count
    final appBadgeCount = await _getAppInternalBadgeCount();
    
    if (systemBadgeCount != appBadgeCount) {
      // Sync if there's a mismatch
      await NotificationBadgePlus.setBadgeCount(appBadgeCount);
      print('Badge synced: $appBadgeCount');
    }
  } catch (e) {
    print('Badge sync error: $e');
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Badge Not Showing in Background (Android)

**Problem**: Badge disappears when app goes to background on some Android devices.

**Solution**:
```dart
// Xiaomi/MIUI: the plugin updates the launcher badge via broadcast/provider (no helper notification).
// If the badge still fails, check MIUI app icon badge permission and launcher notification settings.
final manufacturer = (await NotificationBadgePlus.getDeviceManufacturer()).toLowerCase();
if (manufacturer.contains('xiaomi') ||
    manufacturer.contains('redmi') ||
    manufacturer.contains('poco')) {
  // Optionally verify NotificationBadgePlus.isSupported() and OEM badge toggles in system Settings.
}
await NotificationBadgePlus.setBadgeCount(badgeCount);
```

#### 2. Badge Count Mismatch After App Resume

**Problem**: Badge count doesn't match expected value when app returns to foreground.

**Solution**:
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Always sync badge count on resume
    _syncBadgeOnResume();
  }
}

Future<void> _syncBadgeOnResume() async {
  final currentCount = await NotificationBadgePlus.getBadgeCount();
  // Update your app's internal state
  _updateInternalBadgeCount(currentCount);
}
```

#### 3. iOS Badge Not Persisting

**Problem**: Badge disappears on iOS after some time.

**Solution**:
```dart
// Ensure proper permissions are requested
await _requestNotificationPermissions();

Future<void> _requestNotificationPermissions() async {
  final settings = await UNUserNotificationCenter.current()
      .getNotificationSettings();
  
  if (settings.authorizationStatus != UNAuthorizationStatus.authorized) {
    await UNUserNotificationCenter.current()
        .requestAuthorization(options: [.badge, .alert, .sound]);
  }
}
```

#### 4. Android Badge Not Working on Specific Manufacturers

**Problem**: Badge doesn't show on certain Android manufacturers.

**Solution**:
```dart
// Check if badge is supported and provide fallback
final isSupported = await NotificationBadgePlus.isSupported();
if (!isSupported) {
  // Show in-app indicator instead
  _showInAppBadgeIndicator(count);
} else {
  await NotificationBadgePlus.setBadgeCount(count);
}
```

### Performance Considerations

#### 1. Minimize Badge Updates
```dart
// Debounce rapid badge updates
Timer? _badgeUpdateTimer;

void debouncedBadgeUpdate(int count) {
  _badgeUpdateTimer?.cancel();
  _badgeUpdateTimer = Timer(Duration(milliseconds: 500), () {
    NotificationBadgePlus.setBadgeCount(count);
  });
}
```

#### 2. Cache Badge Status
```dart
class BadgeCache {
  static int? _cachedBadgeCount;
  static DateTime? _lastUpdate;
  
  static Future<int> getCachedBadgeCount() async {
    if (_cachedBadgeCount == null || 
        DateTime.now().difference(_lastUpdate!) > Duration(minutes: 1)) {
      _cachedBadgeCount = await NotificationBadgePlus.getBadgeCount();
      _lastUpdate = DateTime.now();
    }
    return _cachedBadgeCount!;
  }
}
```

## Conclusion

The notification_badge_plus plugin provides robust background and foreground badge handling across iOS and Android platforms. By following the patterns and best practices outlined in this guide, you can ensure reliable badge functionality regardless of app state or platform-specific limitations.

Key takeaways:
- iOS provides native badge persistence and background updates
- Android requires manufacturer-specific approaches and careful state management
- Always implement proper app lifecycle handling
- Provide fallbacks for unsupported devices
- Test thoroughly across different manufacturers and OS versions