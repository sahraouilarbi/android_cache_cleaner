package com.example.android_cache_cleaner

import android.app.AppOpsManager
import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.cacheflow/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppStats" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        if (hasUsageStatsPermission()) {
                            CoroutineScope(Dispatchers.IO).launch {
                                val stats = getAppStats()
                                withContext(Dispatchers.Main) {
                                    result.success(stats)
                                }
                            }
                        } else {
                            // Prompt for permission
                            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                            result.error("PERMISSION_DENIED", "Usage stats permission required", null)
                        }
                    } else {
                        result.error("UNSUPPORTED_OS", "Requires Android O or higher", null)
                    }
                }
                "clearCache" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    result.success(clearCacheRoot(packages))
                }
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityEnabled())
                }
                "requestAccessibilityService" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }
                "triggerAccessibilityCleaning" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    if (isAccessibilityEnabled()) {
                        CacheAccessibilityService.startCleaning(packages)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun getAppStats(): List<Map<String, Any>> {
        val statsManager = getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val pm = packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val result = mutableListOf<Map<String, Any>>()

        for (app in apps) {
            if ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue // Skip system apps
            
            try {
                val stats = statsManager.queryStatsForUid(app.storageUuid, app.uid)
                val cacheSize = stats.cacheBytes
                val dataSize = stats.dataBytes
                val apkSize = stats.appBytes
                
                val iconBytes = try {
                    val iconDrawable = pm.getApplicationIcon(app)
                    getIconByteArray(iconDrawable)
                } catch (e: Exception) {
                    null
                }

                result.add(mapOf(
                    "packageName" to app.packageName,
                    "appName" to pm.getApplicationLabel(app).toString(),
                    "cacheSize" to cacheSize,
                    "dataSize" to dataSize,
                    "apkSize" to apkSize,
                    "iconBytes" to iconBytes
                ).filterValues { it != null } as Map<String, Any>)
            } catch (e: Exception) {
                // Handle security exception or UUID errors silently
            }
        }
        return result
    }

    private fun getIconByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        // Compression is necessary for serialization and reducing payload size
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun clearCacheRoot(packages: List<String>): Boolean {
        try {
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)
            for (pkg in packages) {
                os.writeBytes("rm -rf /data/user/0/$pkg/cache/*\n")
            }
            os.writeBytes("exit\n")
            os.flush()
            process.waitFor()
            return process.exitValue() == 0
        } catch (e: Exception) {
            return false
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val expectedId = "$packageName/${CacheAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        return enabledServices?.contains(expectedId) == true
    }
}
