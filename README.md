# notification_badge_plus

A comprehensive Flutter plugin for displaying notification badges on app icons with extensive Android support and full iOS compatibility.

## Features

### 🚀 Comprehensive Android Support
- **Samsung**: Native BadgeProvider integration for all Samsung devices
- **Xiaomi/Redmi/POCO**: Notification-based badge implementation optimized for MIUI
- **Huawei/Honor**: EMUI-compatible badge system with broadcast support
- **OPPO/OnePlus/Realme**: ColorOS and OxygenOS launcher integration
- **Vivo/iQOO**: FuntouchOS badge support
- **Sony**: Xperia launcher badge implementation
- **HTC**: Sense UI badge support
- **LG**: LG UX launcher compatibility
- **Nova Launcher**: TeslaUnread integration
- **Android Oreo+**: Native notification badges for stock Android

### 🍎 Full iOS Support
- **iOS 9.0+**: Complete compatibility across all iOS versions
- **iOS 16+**: Uses latest UNUserNotificationCenter APIs
- **Legacy iOS**: Fallback to UIApplication badge methods
- **Background/Foreground**: Automatic state management

### 🔧 Key Features
- Cross-platform API with consistent behavior
- Background and foreground app state handling
- Device manufacturer detection
- Comprehensive error handling and logging
- No external dependencies required
- Easy integration and setup

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  notification_badge_plus: ^1.0.6
```

## Usage

### Basic Usage

```dart
import 'package:notification_badge_plus/notification_badge_plus.dart';

// Set badge count
await NotificationBadgePlus.setBadgeCount(5);

// Get current badge count
int count = await NotificationBadgePlus.getBadgeCount();

// Clear badge
await NotificationBadgePlus.clearBadge();

// Increment/Decrement
int newCount = await NotificationBadgePlus.incrementBadge();
int decrementedCount = await NotificationBadgePlus.decrementBadge();

// Get device manufacturer (Android only)
String manufacturer = await NotificationBadgePlus.getDeviceManufacturer();

// Check notification permissions (Required for iOS)
bool hasPermission = await NotificationBadgePlus.checkPermissions();

// Request notification permissions
if (!hasPermission) {
  bool granted = await NotificationBadgePlus.requestPermissions();
}
```

### Advanced Usage with Error Handling

```dart
try {
  bool success = await NotificationBadgePlus.setBadgeCount(10);
  if (success) {
    print('Badge set successfully!');
  } else {
    print('Failed to set badge - device may not support badges');
  }
} catch (e) {
  print('Error setting badge: $e');
}
```

### Handling App Lifecycle

The plugin automatically handles app lifecycle changes, but you can also manually sync the badge count:

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        // App came to foreground - sync badge count
        _syncBadgeOnResume();
        break;
      case AppLifecycleState.paused:
        // App going to background - save current state
        _saveBadgeState();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _saveBadgeState();
        break;
      default:
        break;
    }
  }

  Future<void> _syncBadgeOnResume() async {
    try {
      final currentCount = await NotificationBadgePlus.getBadgeCount();
      // Update your UI with the current count
      setState(() {
        // Update your badge count state
      });
    } catch (e) {
      print('Error syncing badge: $e');
    }
  }

  Future<void> _saveBadgeState() async {
    // Ensure badge count is persisted
    // The plugin handles this automatically, but you can add custom logic here
  }
}
```

### Background and Foreground Badge Management

For detailed information about handling badges in background and foreground scenarios, see the comprehensive guide: [Background and Foreground Handling Guide](BACKGROUND_FOREGROUND_GUIDE.md)

**Key Background/Foreground Features:**
- ✅ **Automatic State Management**: Plugin handles app lifecycle automatically
- ✅ **Badge Persistence**: Counts persist across app states and device restarts
- ✅ **Background Updates**: iOS supports background badge updates natively
- ✅ **Android Manufacturer Support**: Different strategies for various manufacturers
- ✅ **Push Notification Integration**: Seamless integration with push notifications
- ✅ **Cross-Platform Sync**: Consistent behavior across iOS and Android

### Push Notification Integration Example

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notification_badge_plus/notification_badge_plus.dart';

// Handle background push notifications
static Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final badgeCount = int.tryParse(message.data['badge'] ?? '1') ?? 1;
  final currentCount = await NotificationBadgePlus.getBadgeCount();
  await NotificationBadgePlus.setBadgeCount(currentCount + badgeCount);
}

// Handle foreground push notifications
static Future<void> handleForegroundMessage(RemoteMessage message) async {
  final badgeCount = int.tryParse(message.data['badge'] ?? '1') ?? 1;
  await NotificationBadgePlus.incrementBadge();
}

// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  
  runApp(MyApp());
}
```

## Platform Support

### Android Requirements
- **Minimum SDK**: Android 16 (API level 16)
- **Target SDK**: Android 35
- **Permissions**: All required permissions are automatically included

### iOS Requirements
- **Minimum iOS**: 9.0
- **Swift Version**: 5.0
- **Automatic**: No additional setup required

## Android Implementation Details

### Samsung Devices
Uses Samsung's native BadgeProvider content resolver system. Supports both old and new Samsung devices with automatic fallback methods.

### Xiaomi Devices (MIUI)
Implements notification-based badges optimized for MIUI. Creates low-priority notifications that enable badge display without disturbing the user.

### Huawei Devices (EMUI)
Utilizes Huawei's badge provider and broadcast system. Compatible with various EMUI versions.

### OPPO/OnePlus/Realme
Supports ColorOS and OxygenOS specific badge implementations with multiple fallback methods.

### Other Manufacturers
Comprehensive support for Sony, HTC, LG, and Vivo devices using their respective launcher protocols.

## Troubleshooting

### Android Badge Not Showing

1. **Check Device Support**:
```dart
bool supported = await NotificationBadge.isSupported();
if (!supported) {
  print('Badges not supported on this device');
}
```

2. **Check Manufacturer**:
```dart
String manufacturer = await NotificationBadge.getDeviceManufacturer();
print('Device manufacturer: $manufacturer');
```

3. **Enable Badge Permissions**: Some devices require users to manually enable badge notifications in Settings > Apps > [Your App] > Notifications > App Icon Badges.

### iOS Badge Not Showing

1. **Check Notification Permissions**: iOS requires notification permissions for badges. You can use the built-in methods:
```dart
bool hasPermission = await NotificationBadgePlus.checkPermissions();
if (!hasPermission) {
  await NotificationBadgePlus.requestPermissions();
}
```

Alternatively, you can use the `permission_handler` package:
```dart
// Request notification permissions
import 'package:permission_handler/permission_handler.dart';

await Permission.notification.request();
```

2. **Check iOS Settings**: Users can disable badges in Settings > Notifications > [Your App] > Badges.

## Technical Details

### Android Implementation
- Uses multiple badge provider implementations
- Automatic manufacturer detection and provider selection
- SharedPreferences for badge count persistence
- Comprehensive error handling and logging

### iOS Implementation
- Uses UNUserNotificationCenter for iOS 16+
- Falls back to UIApplication for older iOS versions
- Automatic app lifecycle management
- Thread-safe implementation

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.