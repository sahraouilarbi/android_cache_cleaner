package com.sahraouilarbi.android_cache_cleaner

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
import android.util.Log
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
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.sahraouilarbi.cacheflow/native"
    // SECURITY: Strict regex to validate Android package names
    private val PACKAGE_NAME_REGEX = Regex("^[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z][a-zA-Z0-9_]*)+$")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getAppStats" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            if (hasUsageStatsPermission()) {
                                CoroutineScope(Dispatchers.IO).launch {
                                    try {
                                        val stats = getAppStats()
                                        withContext(Dispatchers.Main) {
                                            result.success(stats)
                                        }
                                    } catch (e: Exception) {
                                        withContext(Dispatchers.Main) {
                                            result.error("STORAGE_STATS_ERROR", "Could not retrieve app stats", null)
                                        }
                                    }
                                }
                            } else {
                                startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                                result.error("PERMISSION_DENIED", "Usage stats permission required", null)
                            }
                        } else {
                            result.error("UNSUPPORTED_OS", "Requires Android O or higher", null)
                        }
                    }
                    "clearCache" -> {
                        val packages = call.argument<List<String>>("packages")
                        if (packages == null || packages.isEmpty()) {
                            result.error("INVALID_ARGUMENT", "Package list is required", null)
                            return@setMethodCallHandler
                        }
                        
                        // SECURITY: Validate each package name before passing to root shell
                        for (pkg in packages) {
                            if (!PACKAGE_NAME_REGEX.matches(pkg)) {
                                result.error("SECURITY_ERROR", "Invalid package name format detected", null)
                                return@setMethodCallHandler
                            }
                        }

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
                        val packages = call.argument<List<String>>("packages")
                        if (packages == null || packages.isEmpty()) {
                            result.error("INVALID_ARGUMENT", "Package list is required", null)
                            return@setMethodCallHandler
                        }

                        // SECURITY: Validate package names for accessibility queue
                        for (pkg in packages) {
                            if (!PACKAGE_NAME_REGEX.matches(pkg)) {
                                result.error("SECURITY_ERROR", "Invalid package name format", null)
                                return@setMethodCallHandler
                            }
                        }

                        if (isAccessibilityEnabled()) {
                            // Use Broadcast instead of static instance for better architecture
                            val intent = Intent(CacheAccessibilityService.ACTION_START_CLEANING).apply {
                                `package` = packageName
                                putStringArrayListExtra(CacheAccessibilityService.EXTRA_PACKAGES, ArrayList(packages))
                            }
                            sendBroadcast(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                // SECURITY: Catch all exceptions to prevent internal info leakage
                Log.e("CacheFlow", "Native exception caught: ${e.message}", e)
                result.error("UNEXPECTED_ERROR", "An unexpected error occurred in native code", null)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun getAppStats(): List<Map<String, Any>> {
        val statsManager = getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val pm = packageManager
        
        val apps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(PackageManager.GET_META_DATA.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledApplications(PackageManager.GET_META_DATA)
        }

        val result = mutableListOf<Map<String, Any>>()

        for (app in apps) {
            // Filter out system apps that are not updated (original system apps)
            // We usually only want to clean third-party apps or system apps that the user actually uses
            val isSystemApp = (app.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            val isUpdatedSystemApp = (app.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            
            if (isSystemApp && !isUpdatedSystemApp) continue 
            if (app.packageName == packageName) continue // Skip ourselves
            
            try {
                val stats = statsManager.queryStatsForUid(app.storageUuid, app.uid)
                val cacheSize = stats.cacheBytes
                
                // Only include apps with some cache or relevant size
                if (cacheSize <= 0) continue

                val dataSize = stats.dataBytes
                val apkSize = stats.appBytes
                
                val iconBytes = try {
                    val iconDrawable = app.loadIcon(pm)
                    getIconByteArray(iconDrawable)
                } catch (e: Exception) {
                    null
                }

                val appMap = mutableMapOf<String, Any>(
                    "packageName" to app.packageName,
                    "appName" to pm.getApplicationLabel(app).toString(),
                    "cacheSize" to cacheSize,
                    "dataSize" to dataSize,
                    "apkSize" to apkSize
                )
                
                if (iconBytes != null) {
                    appMap["iconBytes"] = iconBytes
                }

                result.add(appMap)
            } catch (e: Exception) {
                // Some apps might not be accessible or queryable
                Log.e("CacheFlow", "Error querying stats for ${app.packageName}: ${e.message}")
            }
        }
        
        // Sort by cache size descending
        return result.sortedByDescending { it["cacheSize"] as Long }
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
                // SECURITY: Use File API to resolve canonical path and prevent path traversal
                val cacheDir = File("/data/user/0/$pkg/cache")
                val resolvedPath = cacheDir.canonicalPath
                
                // Verify path is within expected sandbox scope
                if (resolvedPath.startsWith("/data/user/0/$pkg/")) {
                    os.writeBytes("rm -rf $resolvedPath/*\n")
                } else {
                    Log.e("CacheFlow", "Blocked suspicious path traversal attempt: $resolvedPath")
                }
            }
            os.writeBytes("exit\n")
            os.flush()
            process.waitFor()
            return process.exitValue() == 0
        } catch (e: Exception) {
            Log.e("CacheFlow", "Root cleaning failed: ${e.message}")
            return false
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val expectedId = "$packageName/${CacheAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        return enabledServices?.contains(expectedId) == true
    }
}
