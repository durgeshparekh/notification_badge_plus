package com.dp.notification_badge_plus

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle

class OppoBadgeProvider(private val context: Context) : BadgeProvider {
    
    override fun isSupported(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        // OnePlus is handled by OnePlusBadgeProvider; avoid duplicate broadcasts on OnePlus devices.
        return manufacturer.contains("oppo") || manufacturer.contains("realme")
    }

    override fun setBadgeCount(count: Int): Boolean {
        return try {
            // Method 1: Try OPPO launcher broadcast
            if (tryOppoBroadcast(count)) {
                return true
            }
            
            // Method 2: Try OnePlus launcher broadcast (for OnePlus devices)
            if (tryOnePlusBroadcast(count)) {
                return true
            }
            
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun tryOppoBroadcast(count: Int): Boolean {
        return try {
            val intent = Intent("com.oppo.launcher.action.UPDATE_COUNT").apply {
                putExtra("packageName", context.packageName)
                putExtra("count", count)
                putExtra("upgradeNumber", count)
                putExtra("className", getLauncherActivityClass())
            }
            
            context.sendBroadcast(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun tryOnePlusBroadcast(count: Int): Boolean {
        return try {
            val intent = Intent("com.oneplus.launcher.action.UPDATE_BADGE").apply {
                putExtra("packageName", context.packageName)
                putExtra("className", getLauncherActivityClass())
                putExtra("count", count)
            }
            
            context.sendBroadcast(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun getLauncherActivityClass(): String {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        return intent?.component?.className ?: ""
    }
}