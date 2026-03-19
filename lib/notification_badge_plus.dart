import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationBadgePlus {
  static const MethodChannel _channel = MethodChannel('notification_badge');

  /// Enable or disable debug logging
  static bool enableLogging = kDebugMode;

  static void _log(String message) {
    if (enableLogging) {
      if (kDebugMode) {
        print('[NotificationBadgePlus] $message');
      }
    }
  }

  /// Sets the badge count on the app icon
  /// Returns true if successful, false otherwise
  static Future<bool> setBadgeCount(int count) async {
    _log('setBadgeCount called with count: $count');

    if (count < 0) {
      _log('Error: Badge count cannot be negative: $count');
      throw ArgumentError('Badge count cannot be negative');
    }

    try {
      _log('Invoking native setBadgeCount method...');
      final result = await _channel.invokeMethod(
        'setBadgeCount',
        {'count': count},
      );
      final success = result == true;
      _log('setBadgeCount result: $success');
      return success;
    } catch (e) {
      _log('setBadgeCount failed with error: $e');
      if (kDebugMode) {
        print('NotificationBadge: Failed to set badge count: $e');
      }
      return false;
    }
  }

  /// Gets the current badge count
  /// Returns the current badge count, or 0 if unable to retrieve
  static Future<int> getBadgeCount() async {
    _log('getBadgeCount called');

    try {
      _log('Invoking native getBadgeCount method...');
      final result = await _channel.invokeMethod<int>('getBadgeCount');
      final count = result ?? 0;
      _log('getBadgeCount result: $count');
      return count;
    } catch (e) {
      _log('getBadgeCount failed with error: $e');
      if (kDebugMode) {
        print('NotificationBadge: Failed to get badge count: $e');
      }
      return 0;
    }
  }

  /// Clears the badge count (sets it to 0)
  /// Returns true if successful, false otherwise
  static Future<bool> clearBadge() async {
    _log('clearBadge called');
    return setBadgeCount(0);
  }

  /// Checks if the device supports badge notifications
  /// Returns true if supported, false otherwise
  static Future<bool> isSupported() async {
    _log('isSupported called');

    try {
      _log('Invoking native isSupported method...');
      final result = await _channel.invokeMethod('isSupported');
      final supported = result == true;
      _log('isSupported result: $supported');
      return supported;
    } catch (e) {
      _log('isSupported failed with error: $e');
      if (kDebugMode) {
        print('NotificationBadge: Failed to check support: $e');
      }
      return false;
    }
  }

  /// Increments the badge count by 1
  /// Returns the new badge count, or current count if failed
  static Future<int> incrementBadge() async {
    _log('incrementBadge called');

    try {
      final currentCount = await getBadgeCount();
      _log('Current badge count before increment: $currentCount');
      final newCount = currentCount + 1;
      final success = await setBadgeCount(newCount);
      final result = success ? newCount : currentCount;
      _log('incrementBadge result: $result (success: $success)');
      return result;
    } catch (e) {
      _log('incrementBadge failed with error: $e');
      if (kDebugMode) {
        print('NotificationBadge: Failed to increment badge: $e');
      }
      return await getBadgeCount();
    }
  }

  /// Decrements the badge count by 1 (minimum 0)
  /// Returns the new badge count, or current count if failed
  static Future<int> decrementBadge() async {
    _log('decrementBadge called');

    try {
      final currentCount = await getBadgeCount();
      _log('Current badge count before decrement: $currentCount');
      final newCount = (currentCount - 1).clamp(0, double.infinity).toInt();
      _log('Calculated new badge count: $newCount');
      final success = await setBadgeCount(newCount);
      final result = success ? newCount : currentCount;
      _log('decrementBadge result: $result (success: $success)');
      return result;
    } catch (e) {
      _log('decrementBadge failed with error: $e');
      if (kDebugMode) {
        print('NotificationBadge: Failed to decrement badge: $e');
      }
      return await getBadgeCount();
    }
  }

  /// Gets device manufacturer information (Android only)
  /// Returns manufacturer name, or empty string if not available
  static Future<String> getDeviceManufacturer() async {
    _log('getDeviceManufacturer called');

    if (!Platform.isAndroid) {
      _log('Not Android platform, returning empty string');
      return '';
    }

    try {
      _log('Invoking native getDeviceManufacturer method...');
      final result = await _channel.invokeMethod<String>(
        'getDeviceManufacturer',
      );
      final manufacturer = result ?? '';
      _log('getDeviceManufacturer result: $manufacturer');
      return manufacturer;
    } catch (e) {
      _log('getDeviceManufacturer failed with error: $e');
      if (kDebugMode) {
        print('NotificationBadge: Failed to get device manufacturer: $e');
      }
      return '';
    }
  }

  /// Checks if the app has notification permissions (specifically for badges)
  /// On iOS, this checks if the user has granted notification permissions.
  /// management doesn't usually require explicit user permission beyond 
  /// notification state.
  static Future<bool> checkPermissions() async {
    _log('checkPermissions called');

    if (Platform.isAndroid) {
      return true;
    }

    try {
      _log('Invoking native checkPermissions method...');
      final result = await _channel.invokeMethod('checkPermissions');
      final authorized = result == true;
      _log('checkPermissions result: $authorized');
      return authorized;
    } catch (e) {
      _log('checkPermissions failed with error: $e');
      return false;
    }
  }

  /// Requests notification permissions (including badges)
  /// This is highly recommended for iOS before attempting to set badges.
  /// Returns true if permission was granted or if on Android.
  static Future<bool> requestPermissions() async {
    _log('requestPermissions called');

    if (Platform.isAndroid) {
      return true;
    }

    try {
      _log('Invoking native requestPermissions method...');
      final result = await _channel.invokeMethod('requestPermissions');
      final granted = result == true;
      _log('requestPermissions result: $granted');
      return granted;
    } catch (e) {
      _log('requestPermissions failed with error: $e');
      return false;
    }
  }
}
