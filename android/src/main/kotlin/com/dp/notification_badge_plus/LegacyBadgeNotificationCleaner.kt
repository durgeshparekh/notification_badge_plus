package com.dp.notification_badge_plus

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log

/**
 * Removes notification channels and notifications that were posted by older
 * versions of this plugin to "trick" launchers into showing a badge.
 *
 * Older versions created visible categories such as "App Badge Notifications" /
 * "Badge Notifications" and silent posts titled "Badge Count". The current
 * plugin no longer creates any notifications, so this cleaner removes any
 * stale artifacts on app start and before each `setBadgeCount` call so users
 * upgrading from older versions get a clean state automatically.
 */
internal object LegacyBadgeNotificationCleaner {
    private const val TAG = "NotificationBadgePlus"

    private val LEGACY_CHANNEL_IDS = listOf(
        // AndroidOreoDefaultBadgeProvider (1.0.0 - 1.0.6)
        "notification_badge_channel",
        // XiaomiBadgeProvider (1.0.0 - 1.0.6)
        "badge_notification_channel"
    )

    private val LEGACY_NOTIFICATION_IDS = listOf(
        1000, // AndroidOreoDefaultBadgeProvider
        1001  // XiaomiBadgeProvider
    )

    fun cleanup(context: Context) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as? NotificationManager ?: return

        cancelLegacyNotificationsById(notificationManager)
        cancelActiveNotificationsForLegacyChannels(notificationManager)
        deleteLegacyChannels(notificationManager)
    }

    private fun cancelLegacyNotificationsById(notificationManager: NotificationManager) {
        for (id in LEGACY_NOTIFICATION_IDS) {
            try {
                notificationManager.cancel(id)
            } catch (e: Exception) {
                Log.w(TAG, "Failed to cancel legacy notification id=$id: ${e.message}")
            }
        }
    }

    private fun cancelActiveNotificationsForLegacyChannels(
        notificationManager: NotificationManager
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        try {
            val active = notificationManager.activeNotifications ?: return
            for (sbn in active) {
                val channelId = sbn.notification?.channelId ?: continue
                if (channelId in LEGACY_CHANNEL_IDS) {
                    try {
                        if (sbn.tag != null) {
                            notificationManager.cancel(sbn.tag, sbn.id)
                        } else {
                            notificationManager.cancel(sbn.id)
                        }
                    } catch (e: Exception) {
                        Log.w(
                            TAG,
                            "Failed to cancel active legacy notification id=${sbn.id}: ${e.message}"
                        )
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to enumerate active notifications: ${e.message}")
        }
    }

    private fun deleteLegacyChannels(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        for (channelId in LEGACY_CHANNEL_IDS) {
            try {
                notificationManager.deleteNotificationChannel(channelId)
            } catch (e: Exception) {
                Log.w(TAG, "Failed to delete legacy channel $channelId: ${e.message}")
            }
        }
    }
}
