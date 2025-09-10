## 1.0.0

- **Initial release of notification_badge_plus package**

### 🚀 Core Features

- Comprehensive Android support for notification badges including:
  - Samsung devices with native BadgeProvider integration
  - Xiaomi/Redmi/POCO devices with notification-based badges optimized for MIUI
  - Huawei/Honor devices with EMUI-compatible badge system
  - OPPO/OnePlus/Realme devices with ColorOS and OxygenOS support
  - Vivo/iQOO devices with FuntouchOS badge support
  - Sony devices with Xperia launcher integration
  - HTC devices with Sense UI badge support
  - LG devices with LG UX launcher compatibility
  - Nova Launcher support with TeslaUnread integration
  - Android Oreo+ default notification badges for stock Android

### 🍎 iOS Support

- Full iOS support for all iOS versions (9.0+)
- iOS 16+ compatibility with latest UNUserNotificationCenter APIs
- Legacy iOS support with UIApplication fallback methods
- Automatic background and foreground state management
- Badge persistence across app states and device restarts

### 🔄 Background/Foreground Handling

- Automatic app lifecycle management with WidgetsBindingObserver integration
- Badge count persistence across all app states (foreground, background, terminated)
- Seamless synchronization when app returns to foreground
- Push notification integration with background badge updates
- Cross-platform consistent behavior

### 📱 API Methods

- `setBadgeCount(int count)` - Set badge count with validation
- `getBadgeCount()` - Retrieve current badge count
- `clearBadge()` - Clear badge (set to 0)
- `incrementBadge()` - Increment badge by 1
- `decrementBadge()` - Decrement badge by 1 (minimum 0)
- `isSupported()` - Check device badge support
- `getDeviceManufacturer()` - Get device manufacturer (Android)

### 📚 Documentation

- Comprehensive README with usage examples and platform-specific details
- [Background and Foreground Handling Guide](BACKGROUND_FOREGROUND_GUIDE.md) - Detailed guide for lifecycle management
- [Quick Reference Guide](QUICK_REFERENCE.md) - Fast reference for common scenarios
- Complete example app demonstrating all features
- Troubleshooting guides for common issues
- Best practices and performance considerations

### 🔧 Technical Implementation

- Cross-platform API with consistent error handling
- Device manufacturer detection for optimal Android handling
- SharedPreferences persistence on Android
- Thread-safe iOS implementation
- Comprehensive logging and debugging support
- No external dependencies required
- Flutter 3.0+ and Dart 3.0+ compatibility

## 1.0.1

- Added `SERVER_PAYLOAD_GUIDE.md` with comprehensive instructions for server-side badge payloads (iOS/Android/FCM/APNs).
- Replaced all instances of "OEM" with "manufacturer" for clarity and consistency across documentation and code.
- Enhanced logging in Dart, Android (Kotlin), and iOS (Swift) code to improve workflow visibility in debug mode.
- Documentation updated to reflect terminology and logging improvements

## 1.0.2

- **🔧 Fixed iOS compilation errors** - Resolved Swift compiler errors by removing non-existent `getBadgeCount` API calls
- **📱 Improved iOS compatibility** - Use `UIApplication.applicationIconBadgeNumber` for consistent badge retrieval across all iOS versions
