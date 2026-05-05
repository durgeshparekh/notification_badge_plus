package com.dp.notification_badge_plus

import android.content.Context
import android.content.SharedPreferences
import android.util.Log

class BadgeHelper(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("notification_badge", Context.MODE_PRIVATE)
    private val badgeProviders: List<BadgeProvider> = listOf(
        SamsungBadgeProvider(context),
        XiaomiBadgeProvider(context),
        HuaweiBadgeProvider(context),
        OppoBadgeProvider(context),
        VivoBadgeProvider(context),
        OnePlusBadgeProvider(context),
        SonyBadgeProvider(context),
        HTCBadgeProvider(context),
        LGBadgeProvider(context),
        NovaLauncherBadgeProvider(context)
    )

    fun setBadgeCount(count: Int): Boolean {
        Log.d("NotificationBadgePlus", "setBadgeCount called with count: $count")

        // Defensive: if the user upgraded from an older plugin version that
        // posted helper notifications, remove them on every set call. Cheap.
        LegacyBadgeNotificationCleaner.cleanup(context)

        try {
            // Store the count in SharedPreferences for persistence
            prefs.edit().putInt("badge_count", count).apply()
            Log.d("NotificationBadgePlus", "Badge count stored in SharedPreferences: $count")
            
            var anySuccess = false
            val supportedProviders = badgeProviders.filter { it.isSupported() }
            Log.d("NotificationBadgePlus", "Found ${supportedProviders.size} supported badge providers")
            
            for (provider in supportedProviders) {
                val providerName = provider.javaClass.simpleName
                Log.d("NotificationBadgePlus", "Attempting to set badge using: $providerName")
                
                try {
                    if (provider.setBadgeCount(count)) {
                        anySuccess = true
                        Log.d("NotificationBadgePlus", "Successfully set badge using $providerName")
                    } else {
                        Log.w("NotificationBadgePlus", "Failed to set badge using $providerName (returned false)")
                    }
                } catch (e: Exception) {
                    Log.w("NotificationBadgePlus", "Failed to set badge using $providerName: ${e.message}")
                }
            }
            
            Log.d("NotificationBadgePlus", "setBadgeCount completed. Success: $anySuccess")
            return anySuccess
        } catch (e: Exception) {
            Log.e("NotificationBadgePlus", "Error setting badge count: ${e.message}", e)
            return false
        }
    }

    fun getBadgeCount(): Int {
        val count = prefs.getInt("badge_count", 0)
        Log.d("NotificationBadgePlus", "getBadgeCount returning: $count")
        return count
    }

    fun isSupported(): Boolean {
        val supported = badgeProviders.any { it.isSupported() }
        Log.d("NotificationBadgePlus", "isSupported returning: $supported")
        if (supported) {
            val supportedProviders = getSupportedProviders()
            Log.d("NotificationBadgePlus", "Supported providers: ${supportedProviders.joinToString()}")
        } else {
            Log.w("NotificationBadgePlus", "No badge providers are supported on this device")
        }
        return supported
    }

    fun getSupportedProviders(): List<String> {
        val supportedProviders = badgeProviders.filter { it.isSupported() }.map { it.javaClass.simpleName }
        Log.d("NotificationBadgePlus", "getSupportedProviders returning: ${supportedProviders.joinToString()}")
        return supportedProviders
    }
}