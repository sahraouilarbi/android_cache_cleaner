package com.sahraouilarbi.android_cache_cleaner

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class CacheAccessibilityService : AccessibilityService() {

    companion object {
        var instance: CacheAccessibilityService? = null
        private val packageQueue = mutableListOf<String>()
        var isCleaning = false

        fun startCleaning(packages: List<String>) {
            packageQueue.clear()
            packageQueue.addAll(packages)
            isCleaning = true
            processNext()
        }

        private fun processNext() {
            if (packageQueue.isEmpty()) {
                isCleaning = false
                // Relancer l'application une fois le nettoyage terminé
                val intent = instance?.packageManager?.getLaunchIntentForPackage("com.sahraouilarbi.android_cache_cleaner")
                intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                instance?.startActivity(intent)
                return
            }

            val pkg = packageQueue[0]
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$pkg")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_HISTORY or Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            }
            instance?.startActivity(intent)
        }
    }

    private var isNavigating = false
    private var lastEventTime = 0L
    private val handler = Handler(Looper.getMainLooper())

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.d("CacheFlowAccessibility", "Accessibility Service Connected")
    }

    override fun onUnbind(intent: Intent?): Boolean {
        instance = null
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isCleaning || event == null || isNavigating) return
        
        val currentTime = System.currentTimeMillis()
        if (lastEventTime == 0L) lastEventTime = currentTime

        // If we stay on the same screen/package for more than 5 seconds without progress, skip it
        if (currentTime - lastEventTime > 5000) {
            Log.d("CacheFlow", "Timeout on ${event.packageName}, skipping...")
            lastEventTime = currentTime
            if (packageQueue.isNotEmpty()) {
                packageQueue.removeAt(0)
            }
            processNext()
            return
        }

        val rootNode = rootInActiveWindow ?: return
        lastEventTime = currentTime

        // 1. On cherche d'abord le bouton "Vider le cache" (Si on est déjà dans le menu de stockage)
        val clearCacheKeywords = listOf(
            "clear cache", "vider le cache", "borrar caché", "limpiar caché", 
            "limpar cache", "svuota cache", "cache leeren", "wisat pamięć podręczną",
            "مسح ذاكرة التخزين المؤقت", "مسح التخزين المؤقت"
        )
        val clearCacheNode = findClickableNodeByTexts(rootNode, clearCacheKeywords)
        
        if (clearCacheNode != null) {
            isNavigating = true
            clearCacheNode.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            
            // Wait for action and optional confirmation
            handler.postDelayed({
                // Check for a confirmation dialog "OK" or "Clear"
                val confirmKeywords = listOf("ok", "clear", "supprimer", "vider", "éliminer", "موافق", "مسح")
                val confirmNode = findClickableNodeByTexts(rootInActiveWindow ?: rootNode, confirmKeywords)
                confirmNode?.performAction(AccessibilityNodeInfo.ACTION_CLICK)

                handler.postDelayed({
                    performGlobalAction(GLOBAL_ACTION_BACK) // Go back from Storage to App Info
                    handler.postDelayed({
                        if (packageQueue.isNotEmpty()) {
                            packageQueue.removeAt(0)
                        }
                        isNavigating = false
                        processNext()
                    }, 400)
                }, 300)
            }, 500)
            return
        }

        // 2. Search for "Storage" menu
        val storageKeywords = listOf("storage", "stockage", "almacenamiento", "armazenamento", "memoria", "speicher", "مساحة التخزين", "التخزين")
        val storageNode = findClickableNodeByTexts(rootNode, storageKeywords)
        
        if (storageNode != null) {
            isNavigating = true
            storageNode.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            handler.postDelayed({
                isNavigating = false
            }, 800)
            return
        }

        // 3. Fallback: If we've been on this screen for too long without finding anything, move to next
        // This is a simple safety mechanism
    }

    private fun findClickableNodeByTexts(node: AccessibilityNodeInfo, keywords: List<String>): AccessibilityNodeInfo? {
        val nodeText = node.text?.toString()?.lowercase()
        val nodeDesc = node.contentDescription?.toString()?.lowercase()

        if (nodeText != null || nodeDesc != null) {
            if (keywords.any { (nodeText?.contains(it) == true) || (nodeDesc?.contains(it) == true) }) {
                var clickableNode: AccessibilityNodeInfo? = node
                while (clickableNode != null && !clickableNode.isClickable) {
                    val parent = clickableNode.parent
                    if (parent == null) break
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
        Log.d("CacheFlowAccessibility", "Service Interrupted")
        isCleaning = false
        isNavigating = false
    }
}
