package com.sahraouilarbi.android_cache_cleaner

import android.accessibilityservice.AccessibilityService
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import androidx.annotation.MainThread
import androidx.core.app.NotificationCompat
import android.content.pm.ApplicationInfo
import java.util.ArrayDeque

class CacheAccessibilityService : AccessibilityService() {

    private val isDebugMode: Boolean
        get() = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "cacheflow_cleaning_channel"
        const val ACTION_START_CLEANING = "com.sahraouilarbi.cacheflow.START_CLEANING"
        const val EXTRA_PACKAGES = "extra_packages"
        
        private val PACKAGE_NAME_REGEX = Regex("^[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z][a-zA-Z0-9_]*)+$")
    }

    private val packageQueue = ArrayDeque<String>()
    private var isCleaning = false
    private var isNavigating = false
    private var lastEventTime = 0L
    private val handler = Handler(Looper.getMainLooper())
    private var pollingRunnable: Runnable? = null

    private val cleaningReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ACTION_START_CLEANING) {
                val packages = intent.getStringArrayListExtra(EXTRA_PACKAGES)
                if (packages != null) {
                    startCleaningSession(packages)
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter(ACTION_START_CLEANING)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(cleaningReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(cleaningReceiver, filter)
        }
    }

    override fun onDestroy() {
        unregisterReceiver(cleaningReceiver)
        stopPolling()
        super.onDestroy()
    }

    @MainThread
    private fun startCleaningSession(packages: List<String>) {
        packageQueue.clear()
        packageQueue.addAll(packages)
        isCleaning = true
        showNotification()
        startPolling()
        processNext()
    }

    @MainThread
    private fun processNext() {
        if (packageQueue.isEmpty()) {
            isCleaning = false
            stopPolling()
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }

            // Relancer l'application une fois le nettoyage terminé
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            startActivity(intent)
            return
        }

        val pkg = packageQueue.peekFirst()
        // SECURITY: Validate package name before building URI and starting activity
        if (pkg == null || !PACKAGE_NAME_REGEX.matches(pkg)) {
            packageQueue.removeFirst()
            processNext()
            return
        }

        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:$pkg")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_HISTORY or Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
        }
        startActivity(intent)
    }

    private val ALLOWED_PACKAGES = setOf(
        "com.android.settings", 
        "com.google.android.settings",
        "com.samsung.android.settings",
        "com.miui.securitycenter",
        "com.coloros.safecenter",
        "com.oplus.settings",
        "com.oppo.settings",
        "com.vivo.settings"
    )

    private val STORAGE_MENU_IDS = listOf(
        "com.android.settings:id/storage_settings",
        "com.android.settings:id/storage_menu_item"
    )

    override fun onServiceConnected() {
        super.onServiceConnected()
        createNotificationChannel()
        if (isDebugMode) {
            Log.d("CacheFlowAccessibility", "Accessibility Service Connected")
        }
    }

    private fun startPolling() {
        stopPolling()
        pollingRunnable = object : Runnable {
            override fun run() {
                if (isCleaning && !isNavigating) {
                    val root = rootInActiveWindow
                    if (root != null) {
                        scanAndClick(root)
                    }
                }
                if (isCleaning) {
                    handler.postDelayed(this, 500)
                }
            }
        }
        handler.post(pollingRunnable!!)
    }

    private fun stopPolling() {
        pollingRunnable?.let { handler.removeCallbacks(it) }
        pollingRunnable = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isCleaning || event == null || isNavigating) return
        
        val eventPackage = event.packageName?.toString()
        if (eventPackage !in ALLOWED_PACKAGES) return

        val allowedEventTypes = setOf(
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
        )
        if (event.eventType !in allowedEventTypes) return
        
        val rootNode = rootInActiveWindow ?: return
        scanAndClick(rootNode)
    }

    private fun scanAndClick(rootNode: AccessibilityNodeInfo) {
        if (isNavigating) return

        val currentTime = System.currentTimeMillis()
        if (lastEventTime == 0L) lastEventTime = currentTime

        if (currentTime - lastEventTime > 7000) {
            lastEventTime = currentTime
            if (packageQueue.isNotEmpty()) {
                packageQueue.removeFirst()
            }
            processNext()
            return
        }
        
        lastEventTime = currentTime

        if (isDebugMode) {
            Log.d("CacheFlowDebug", "Scanning window...")
        }

        val clearCacheKeywords = listOf(
            "clear cache", "vider le cache", "effacer le cache", "borrar caché", "limpiar caché", 
            "limpar cache", "svuota cache", "cache leeren", "wisat pamięć podręczną",
            "مسح ذاكرة التخزين المؤقت", "مسح التخزين المؤقت"
        )
        
        val clearCacheNode = findClickableNodeByTexts(rootNode, clearCacheKeywords)
        
        if (clearCacheNode != null) {
            if (!clearCacheNode.isEnabled) {
                isNavigating = true
                performGlobalAction(GLOBAL_ACTION_BACK)
                handler.postDelayed({
                    if (packageQueue.isNotEmpty()) packageQueue.removeFirst()
                    isNavigating = false
                    processNext()
                }, 400)
                return
            }

            isNavigating = true
            clearCacheNode.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            
            handler.postDelayed({
                val confirmKeywords = listOf("ok", "clear", "supprimer", "vider", "effacer", "éliminer", "موافق", "مسح")
                val confirmNode = findNodeByIds(rootInActiveWindow ?: rootNode, listOf("android:id/button1"))
                    ?: findClickableNodeByTexts(rootInActiveWindow ?: rootNode, confirmKeywords)
                
                confirmNode?.performAction(AccessibilityNodeInfo.ACTION_CLICK)

                handler.postDelayed({
                    performGlobalAction(GLOBAL_ACTION_BACK)
                    handler.postDelayed({
                        if (packageQueue.isNotEmpty()) packageQueue.removeFirst()
                        isNavigating = false
                        processNext()
                    }, 500)
                }, 400)
            }, 600)
            return
        }

        val storageKeywords = listOf("storage", "stockage", "utilisation du stockage", "almacenamiento", "armazenamento", "memoria", "speicher", "مساحة التخزين", "التخزين")
        val storageNode = findNodeByIds(rootNode, STORAGE_MENU_IDS)
            ?: findClickableNodeByTexts(rootNode, storageKeywords)
        
        if (storageNode != null) {
            isNavigating = true
            storageNode.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            handler.postDelayed({
                isNavigating = false
            }, 150)
            return
        }
    }

    private fun findNodeByIds(rootNode: AccessibilityNodeInfo, ids: List<String>): AccessibilityNodeInfo? {
        for (id in ids) {
            val nodes = rootNode.findAccessibilityNodeInfosByViewId(id)
            if (nodes != null && nodes.isNotEmpty()) {
                for (node in nodes) {
                    if (node.isEnabled) {
                        var clickableNode = node
                        while (clickableNode != null && !clickableNode.isClickable) {
                            clickableNode = clickableNode.parent ?: break
                        }
                        if (clickableNode?.isClickable == true) return clickableNode
                    }
                }
            }
        }
        return null
    }

    private fun findClickableNodeByTexts(node: AccessibilityNodeInfo, keywords: List<String>): AccessibilityNodeInfo? {
        val nodeText = node.text?.toString()?.lowercase()
        val nodeDesc = node.contentDescription?.toString()?.lowercase()

        if (nodeText != null || nodeDesc != null) {
            if (keywords.any { (nodeText?.contains(it) == true) || (nodeDesc?.contains(it) == true) }) {
                var clickableNode: AccessibilityNodeInfo? = node
                while (clickableNode != null && !clickableNode.isClickable) {
                    val parent = clickableNode.parent ?: break
                    clickableNode = parent
                }
                if (clickableNode != null && clickableNode.isClickable) {
                    return clickableNode
                }
            }
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            val result = findClickableNodeByTexts(child, keywords)
            if (result != null) return result
        }
        return null
    }

    override fun onInterrupt() {
        isCleaning = false
        isNavigating = false
        stopPolling()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "CacheFlow Cleaning"
            val descriptionText = "Notification displayed during automated cleaning"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showNotification() {
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("CacheFlow")
            .setContentText("Nettoyage automatique en cours...")
            .setSmallIcon(R.mipmap.ic_launcher) // Professional icon from resources
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
        
        startForeground(NOTIFICATION_ID, notification)
    }
}
