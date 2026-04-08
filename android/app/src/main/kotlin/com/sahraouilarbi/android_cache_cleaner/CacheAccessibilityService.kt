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

        val rootNode = rootInActiveWindow ?: return

        // 1. On cherche d'abord le bouton "Vider le cache" (Si on est déjà dans le menu de stockage)
        val clearCacheKeywords = listOf("clear cache", "vider le cache", "borrar caché", "limpiar caché", "limpar cache", "svuota cache")
        val clearCacheNode = findClickableNodeByTexts(rootNode, clearCacheKeywords)
        
        if (clearCacheNode != null) {
            isNavigating = true
            if (clearCacheNode.isEnabled) {
                clearCacheNode.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            }
            
            // On attend un peu que l'action s'effectue, on fait retour et on passe à la suite
            handler.postDelayed({
                performGlobalAction(GLOBAL_ACTION_BACK) // Retour aux infos de l'app
                handler.postDelayed({
                    if (packageQueue.isNotEmpty()) {
                        packageQueue.removeAt(0)
                    }
                    isNavigating = false
                    processNext()
                }, 500)
            }, 500)
            return
        }

        // 2. Si on ne trouve pas "Vider le cache", on cherche le menu "Stockage"
        val storageKeywords = listOf("storage", "stockage", "almacenamiento", "armazenamento", "memoria")
        val storageNode = findClickableNodeByTexts(rootNode, storageKeywords)
        
        if (storageNode != null) {
            isNavigating = true
            storageNode.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            // Attendre le changement de vue
            handler.postDelayed({
                isNavigating = false
            }, 1000)
            return
        }
    }

    private fun findClickableNodeByTexts(node: AccessibilityNodeInfo, keywords: List<String>): AccessibilityNodeInfo? {
        if (node.text != null) {
            val text = node.text.toString().lowercase()
            if (keywords.any { text.contains(it) }) {
                // Trouver le parent cliquable si le texte lui-même n'est pas cliquable
                var clickableNode: AccessibilityNodeInfo? = node
                while (clickableNode != null && !clickableNode.isClickable) {
                    clickableNode = clickableNode.parent
                }
                if (clickableNode != null && clickableNode.isClickable) {
                    return clickableNode
                }
            }
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                val result = findClickableNodeByTexts(child, keywords)
                if (result != null) return result
            }
        }
        return null
    }

    override fun onInterrupt() {
        Log.d("CacheFlowAccessibility", "Service Interrupted")
        isCleaning = false
        isNavigating = false
    }
}
