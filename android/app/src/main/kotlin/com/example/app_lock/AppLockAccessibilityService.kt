package com.example.app_lock

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.util.concurrent.ConcurrentHashMap

class AppLockAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "AppLockA11yService"
        const val ACTION_UNLOCK_SUCCESS = "com.example.app_lock.UNLOCK_SUCCESS"
        const val EXTRA_PACKAGE_NAME = "package_name"
        private const val DB_REFRESH_INTERVAL_MS = 30_000L
        private const val DEFAULT_COOLDOWN_MS = 30_000L
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_SERVICE_ENABLED = "flutter.service_enabled"

        private val IGNORED_PACKAGES = setOf(
            "com.android.systemui",
        )

        @Volatile
        var isRunning = false
            private set

        fun isEnabled(context: Context): Boolean {
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false
            val componentName = "${context.packageName}/${AppLockAccessibilityService::class.java.canonicalName}"
            return enabledServices.split(':').any { it.equals(componentName, ignoreCase = true) }
        }
    }

    private val cooldownMap = ConcurrentHashMap<String, Long>()
    private var lockDatabase: LockDatabase? = null
    private var lockOverlay: LockOverlayManager? = null
    private var lastDbRefresh = 0L
    private var lastForegroundPackage: String? = null
    private var launcherPackages = emptySet<String>()

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val pkg = intent?.getStringExtra(EXTRA_PACKAGE_NAME) ?: return
            cooldownMap[pkg] = System.currentTimeMillis()
            lockOverlay?.dismiss()
            Log.d(TAG, "Unlock cooldown set for $pkg")
        }
    }

    private val screenOffReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            lockOverlay?.dismiss()
            lastForegroundPackage = null
            Log.d(TAG, "Screen off — dismissed overlay")
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isRunning = true
        lockDatabase = LockDatabase(this).also { it.open() }
        lockOverlay = LockOverlayManager(this)
        lastDbRefresh = System.currentTimeMillis()
        launcherPackages = queryLauncherPackages()

        LocalBroadcastManager.getInstance(this)
            .registerReceiver(unlockReceiver, IntentFilter(ACTION_UNLOCK_SUCCESS))

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(screenOffReceiver, IntentFilter(Intent.ACTION_SCREEN_OFF), RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(screenOffReceiver, IntentFilter(Intent.ACTION_SCREEN_OFF))
        }

        Log.d(TAG, "Accessibility service connected — launchers: $launcherPackages")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val pkg = event.packageName?.toString() ?: return

        if (!isProtectionEnabled()) return

        handleForegroundApp(pkg)
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility service interrupted")
    }

    override fun onDestroy() {
        isRunning = false
        lockOverlay?.dismiss()
        lockOverlay = null
        try {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(unlockReceiver)
        } catch (_: Exception) {}
        try {
            unregisterReceiver(screenOffReceiver)
        } catch (_: Exception) {}
        lockDatabase?.close()
        lockDatabase = null
        Log.d(TAG, "Accessibility service destroyed")
        super.onDestroy()
    }

    private fun isProtectionEnabled(): Boolean {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_SERVICE_ENABLED, false)
    }

    private fun queryLauncherPackages(): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfos
            .map { it.activityInfo.packageName }
            .filter { it != "com.android.settings" && it != packageName }
            .toSet()
    }

    private fun handleForegroundApp(foreground: String) {
        val db = lockDatabase ?: return

        val now = System.currentTimeMillis()
        if (now - lastDbRefresh > DB_REFRESH_INTERVAL_MS) {
            db.open()
            lastDbRefresh = now
        }

        if (foreground == packageName || IGNORED_PACKAGES.contains(foreground)) {
            return
        }

        if (lockOverlay?.isDetached == true) {
            Log.d(TAG, "Overlay detached by system — cleaning up and re-evaluating $foreground")
            lockOverlay?.dismiss()
            val targetPkg = lastForegroundPackage ?: foreground
            if (db.isPackageLocked(targetPkg)) {
                val profiles = db.getLockedProfiles(targetPkg)
                if (profiles.isNotEmpty()) {
                    showLockOverlay(targetPkg, profiles)
                }
            }
            if (foreground != targetPkg) {
                handleWhileOverlayHidden(foreground, db, now)
            }
            return
        }

        if (lockOverlay?.isShowing == true) {
            handleWhileOverlayShowing(foreground, db, now)
            return
        }

        handleWhileOverlayHidden(foreground, db, now)
    }

    private fun handleWhileOverlayShowing(foreground: String, db: LockDatabase, now: Long) {
        if (foreground == lastForegroundPackage) return

        if (launcherPackages.contains(foreground)) {
            dismissOverlayIfShowing()
            lastForegroundPackage = foreground
            Log.d(TAG, "Launcher detected ($foreground) — dismissed overlay")
            return
        }

        if (db.isPackageLocked(foreground)) {
            val cooldownTime = cooldownMap[foreground]
            if (cooldownTime != null && now - cooldownTime < DEFAULT_COOLDOWN_MS) {
                dismissOverlayIfShowing()
                lastForegroundPackage = foreground
                return
            }
            lockOverlay?.dismiss()
            val profiles = db.getLockedProfiles(foreground)
            if (profiles.isNotEmpty()) {
                lastForegroundPackage = foreground
                showLockOverlay(foreground, profiles)
                Log.d(TAG, "Switched lock overlay to $foreground")
                return
            }
        }

        Log.d(TAG, "Ignoring $foreground while overlay showing (ad/dialog/webview)")
    }

    private fun handleWhileOverlayHidden(foreground: String, db: LockDatabase, now: Long) {
        val cooldownTime = cooldownMap[foreground]
        if (cooldownTime != null && now - cooldownTime < DEFAULT_COOLDOWN_MS) {
            lastForegroundPackage = foreground
            return
        }

        if (!db.isPackageLocked(foreground)) {
            lastForegroundPackage = foreground
            return
        }

        val profiles = db.getLockedProfiles(foreground)
        if (profiles.isEmpty()) {
            lastForegroundPackage = foreground
            return
        }

        lastForegroundPackage = foreground
        showLockOverlay(foreground, profiles)
    }

    private fun showLockOverlay(packageName: String, profiles: List<ProfileData>) {
        if (Settings.canDrawOverlays(this)) {
            lockOverlay?.show(packageName, profiles)
            Log.d(TAG, "Showed lock overlay for $packageName (${profiles.size} profiles)")
        } else {
            Log.w(TAG, "Overlay permission not granted — cannot show lock for $packageName")
        }
    }

    private fun dismissOverlayIfShowing() {
        if (lockOverlay?.isShowing == true) {
            lockOverlay?.dismiss()
        }
    }
}
