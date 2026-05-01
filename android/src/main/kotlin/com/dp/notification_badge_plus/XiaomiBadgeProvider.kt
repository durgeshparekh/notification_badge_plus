package com.dp.notification_badge_plus

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle

class XiaomiBadgeProvider(private val context: Context) : BadgeProvider {
    override fun isSupported(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        return manufacturer.contains("xiaomi") || 
               manufacturer.contains("redmi") || 
               manufacturer.contains("poco") ||
               isXiaomiDevice()
    }

    override fun setBadgeCount(count: Int): Boolean {
        return try {
            // MIUI launcher badge update without creating notifications.
            val intent = Intent("android.intent.action.APPLICATION_MESSAGE_UPDATE").apply {
                putExtra(
                    "android.intent.extra.update_application_component_name",
                    "${context.packageName}/${getLauncherActivityClass()}"
                )
                putExtra(
                    "android.intent.extra.update_application_message_text",
                    if (count <= 0) "" else count.toString()
                )
            }
            context.sendBroadcast(intent)
            true
        } catch (_: Exception) {
            tryViaMiuiContentProvider(count)
        }
    }

    private fun isXiaomiDevice(): Boolean {
        return try {
            val properties = System.getProperties()
            val miuiVersion = properties.getProperty("ro.miui.ui.version.name")
            miuiVersion != null
        } catch (e: Exception) {
            false
        }
    }

    private fun tryViaMiuiContentProvider(count: Int): Boolean {
        return try {
            val bundle = Bundle().apply {
                putString("package", context.packageName)
                putString("class", getLauncherActivityClass())
                putInt("badgenumber", count)
            }
            context.contentResolver.call(
                android.net.Uri.parse("content://com.miui.home.launcher.provider"),
                "setAppBadgeCount",
                null,
                bundle
            )
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun getLauncherActivityClass(): String {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        return launchIntent?.component?.className ?: ""
    }
}
