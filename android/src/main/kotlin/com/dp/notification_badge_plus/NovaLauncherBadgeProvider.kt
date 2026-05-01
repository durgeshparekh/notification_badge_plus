package com.dp.notification_badge_plus

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

class NovaLauncherBadgeProvider(private val context: Context) : BadgeProvider {
    
    companion object {
        private const val NOVA_LAUNCHER_PACKAGE = "com.teslacoilsw.launcher"
        private const val TESLAUNREAD_PACKAGE = "com.teslacoilsw.notifier"
    }
    
    override fun isSupported(): Boolean {
        return isPackageInstalled(NOVA_LAUNCHER_PACKAGE) || isPackageInstalled(TESLAUNREAD_PACKAGE)
    }

    override fun setBadgeCount(count: Int): Boolean {
        return try {
            // Method for Nova Launcher with TeslaUnread
            val intent = Intent("com.teslacoilsw.notifier.SET_COUNT").apply {
                putExtra("count", count)
                putExtra("tag", "${context.packageName}/${getLauncherActivityClass()}")
            }
            
            context.sendBroadcast(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(0)
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getPackageInfo(packageName, 0)
            }
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun getLauncherActivityClass(): String {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        return intent?.component?.className ?: ""
    }
}