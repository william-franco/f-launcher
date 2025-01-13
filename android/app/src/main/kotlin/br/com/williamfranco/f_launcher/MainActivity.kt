package br.com.williamfranco.f_launcher

import android.app.usage.UsageStatsManager
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "br.com.williamfranco.f_launcher/installed_apps"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val messenger = flutterEngine?.dartExecutor?.binaryMessenger
            ?: throw IllegalStateException("FlutterEngine is not initialized")

        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllApps" -> result.success(getAllApps().map { it.toMap() })
                "getSystemApps" -> result.success(getSystemApps().map { it.toMap() })
                "getUserApps" -> result.success(getUserApps().map { it.toMap() })
                "getAppsFromPlayStore" -> result.success(getAppsFromPlayStore().map { it.toMap() })
                "getRecentlyUsedApps" -> result.success(getRecentlyUsedApps().map { it.toMap() })
                "openApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        openApp(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAllApps(): List<AppInfo> {
        return getApps { true }
    }

    private fun getSystemApps(): List<AppInfo> {
        return getApps {
            it.flags and ApplicationInfo.FLAG_SYSTEM != 0 &&
            it.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP == 0
        }
    }

    private fun getUserApps(): List<AppInfo> {
        return getApps {
            it.flags and ApplicationInfo.FLAG_SYSTEM == 0 ||
            it.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0
        }
    }

    private fun getAppsFromPlayStore(): List<AppInfo> {
        return getApps {
            val installer = packageManager.getInstallerPackageName(it.packageName)
            installer == "com.android.vending"
        }
    }

    private fun getRecentlyUsedApps(): List<AppInfo> {
        val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - TimeUnit.DAYS.toMillis(7) // Últimos 7 dias

        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val recentlyUsedPackages = usageStats.map { it.packageName }.toSet()

        return getApps {
            it.packageName in recentlyUsedPackages
        }
    }

    private fun getApps(filter: (ApplicationInfo) -> Boolean): List<AppInfo> {
        val pm: PackageManager = packageManager
        val apps = mutableListOf<AppInfo>()
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)

        for (packageInfo in packages) {
            if (filter(packageInfo)) {
                val icon = pm.getApplicationIcon(packageInfo)
                val iconBitmap = getBitmapFromDrawable(icon)

                val app = AppInfo(
                    name = pm.getApplicationLabel(packageInfo).toString(),
                    packageName = packageInfo.packageName,
                    icon = iconBitmap
                )
                apps.add(app)
            }
        }

        return apps
    }

    private fun openApp(packageName: String) {
        val launchIntent: Intent? = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent != null) {
            startActivity(launchIntent)
        }
    }

    private fun getBitmapFromDrawable(drawable: Drawable): Bitmap {
        return if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else if (drawable is AdaptiveIconDrawable) {
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        } else {
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        }
    }

    companion object {
        data class AppInfo(
            val name: String,
            val packageName: String,
            val icon: Bitmap
        )

        fun AppInfo.toMap(): Map<String, Any> {
            return mapOf(
                "name" to name,
                "packageName" to packageName,
                "icon" to bitmapToByteArray(icon)
            )
        }

        fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            return stream.toByteArray()
        }
    }
}
