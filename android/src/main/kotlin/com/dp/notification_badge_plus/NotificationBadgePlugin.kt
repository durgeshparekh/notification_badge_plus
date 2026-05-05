package com.dp.notification_badge_plus

import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class NotificationBadgePlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var badgeHelper: BadgeHelper

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("NotificationBadgePlus", "Plugin attached to Flutter engine")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "notification_badge")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        // Remove any stale "App Badge Notifications" / "Badge Count" artifacts left
        // behind by older plugin versions before initializing the helper.
        LegacyBadgeNotificationCleaner.cleanup(context)

        badgeHelper = BadgeHelper(context)
        Log.d("NotificationBadgePlus", "Badge helper initialized. Device: ${Build.MANUFACTURER} ${Build.MODEL}")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d("NotificationBadgePlus", "Method call received: ${call.method}")
        
        when (call.method) {
            "setBadgeCount" -> {
                val count = call.argument<Int>("count") ?: 0
                Log.d("NotificationBadgePlus", "setBadgeCount method called with count: $count")
                val success = badgeHelper.setBadgeCount(count)
                Log.d("NotificationBadgePlus", "setBadgeCount result: $success")
                result.success(success)
            }
            "getBadgeCount" -> {
                Log.d("NotificationBadgePlus", "getBadgeCount method called")
                val count = badgeHelper.getBadgeCount()
                Log.d("NotificationBadgePlus", "getBadgeCount result: $count")
                result.success(count)
            }
            "isSupported" -> {
                Log.d("NotificationBadgePlus", "isSupported method called")
                val supported = badgeHelper.isSupported()
                Log.d("NotificationBadgePlus", "isSupported result: $supported")
                result.success(supported)
            }
            "getDeviceManufacturer" -> {
                Log.d("NotificationBadgePlus", "getDeviceManufacturer method called")
                val manufacturer = Build.MANUFACTURER
                Log.d("NotificationBadgePlus", "getDeviceManufacturer result: $manufacturer")
                result.success(manufacturer)
            }
            "cleanLegacyBadgeNotifications" -> {
                Log.d("NotificationBadgePlus", "cleanLegacyBadgeNotifications method called")
                LegacyBadgeNotificationCleaner.cleanup(context)
                result.success(true)
            }
            else -> {
                Log.w("NotificationBadgePlus", "Unimplemented method called: ${call.method}")
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("NotificationBadgePlus", "Plugin detached from Flutter engine")
        channel.setMethodCallHandler(null)
    }
}
