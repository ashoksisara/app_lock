package com.example.app_lock

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap

class AppMonitorService : Service() {

    companion object {
        private const val TAG = "AppMonitorService"
        const val CHANNEL_ID = "app_lock_monitor"
        const val LOCK_CHANNEL_ID = "app_lock_alert"
        const val NOTIFICATION_ID = 1001
        const val LOCK_NOTIFICATION_ID = 1002
        const val ACTION_UNLOCK_SUCCESS = "com.example.app_lock.UNLOCK_SUCCESS"
        const val EXTRA_PACKAGE_NAME = "package_name"
        private const val POLL_INTERVAL_MS = 500L
        private const val DB_REFRESH_INTERVAL_MS = 30_000L
        private const val DEFAULT_COOLDOWN_MS = 30_000L

        @Volatile
        var isRunning = false
            private set

        @Volatile
        var isLockActivityShowing = false
    }

    private val handler = Handler(Looper.getMainLooper())
    private val cooldownMap = ConcurrentHashMap<String, Long>()
    private var lockDatabase: LockDatabase? = null
    private var lockOverlay: LockOverlayManager? = null
    private var lastDbRefresh = 0L
    private var lastForegroundPackage: String? = null

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val pkg = intent?.getStringExtra(EXTRA_PACKAGE_NAME) ?: return
            cooldownMap[pkg] = System.currentTimeMillis()
            isLockActivityShowing = false
            lockOverlay?.dismiss()
            Log.d(TAG, "Unlock cooldown set for $pkg")
        }
    }

    private val pollRunnable = object : Runnable {
        override fun run() {
            poll()
            handler.postDelayed(this, POLL_INTERVAL_MS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        lockDatabase = LockDatabase(this).also { it.open() }
        lockOverlay = LockOverlayManager(this)
        lastDbRefresh = System.currentTimeMillis()

        LocalBroadcastManager.getInstance(this)
            .registerReceiver(unlockReceiver, IntentFilter(ACTION_UNLOCK_SUCCESS))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true
        startForeground(NOTIFICATION_ID, buildNotification())
        handler.removeCallbacks(pollRunnable)
        handler.post(pollRunnable)
        Log.d(TAG, "Service started")
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        handler.removeCallbacks(pollRunnable)
        lockOverlay?.dismiss()
        lockOverlay = null
        LocalBroadcastManager.getInstance(this).unregisterReceiver(unlockReceiver)
        lockDatabase?.close()
        lockDatabase = null
        Log.d(TAG, "Service destroyed")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun poll() {
        val db = lockDatabase ?: return

        val now = System.currentTimeMillis()
        if (now - lastDbRefresh > DB_REFRESH_INTERVAL_MS) {
            db.open()
            lastDbRefresh = now
        }

        val foreground = UsageStatsHelper.getForegroundPackage(this) ?: return

        if (foreground == packageName) {
            dismissOverlayIfShowing()
            return
        }

        if (foreground == lastForegroundPackage && (isLockActivityShowing || lockOverlay?.isShowing == true)) return

        if (foreground != lastForegroundPackage && lockOverlay?.isShowing == true) {
            if (!db.isPackageLocked(foreground)) {
                dismissOverlayIfShowing()
                lastForegroundPackage = foreground
                return
            }
        }

        val cooldownTime = cooldownMap[foreground]
        if (cooldownTime != null && now - cooldownTime < DEFAULT_COOLDOWN_MS) {
            dismissOverlayIfShowing()
            return
        }

        if (!db.isPackageLocked(foreground)) {
            dismissOverlayIfShowing()
            return
        }

        val profiles = db.getLockedProfiles(foreground)
        if (profiles.isEmpty()) {
            dismissOverlayIfShowing()
            return
        }

        lastForegroundPackage = foreground
        isLockActivityShowing = true
        launchLockActivity(foreground, profiles)
    }

    private fun dismissOverlayIfShowing() {
        if (lockOverlay?.isShowing == true) {
            handler.post { lockOverlay?.dismiss() }
            isLockActivityShowing = false
            Log.d(TAG, "Dismissed overlay — user navigated away")
        }
    }

    private fun launchLockActivity(packageName: String, profiles: List<ProfileData>) {
        if (Settings.canDrawOverlays(this)) {
            lockOverlay?.show(packageName, profiles)
            Log.d(TAG, "Showed lock overlay for $packageName (${profiles.size} profiles)")
        } else {
            val jsonArray = JSONArray()
            for (p in profiles) {
                jsonArray.put(JSONObject().apply {
                    put("id", p.id)
                    put("name", p.name)
                    put("emoji", p.emoji)
                    put("hashedPin", p.hashedPin)
                })
            }

            val activityIntent = Intent(this, LockActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra(EXTRA_PACKAGE_NAME, packageName)
                putExtra("profiles_json", jsonArray.toString())
            }

            val fullScreenPendingIntent = PendingIntent.getActivity(
                this, LOCK_NOTIFICATION_ID, activityIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val lockNotification = Notification.Builder(this, LOCK_CHANNEL_ID)
                .setContentTitle("App Locked")
                .setContentText("Tap to unlock")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setCategory(Notification.CATEGORY_CALL)
                .setAutoCancel(true)
                .build()

            val nm = getSystemService(NotificationManager::class.java)
            nm.notify(LOCK_NOTIFICATION_ID, lockNotification)
            Log.d(TAG, "Launched lock notification fallback for $packageName (overlay permission missing)")
        }
    }

    private fun createNotificationChannel() {
        val nm = getSystemService(NotificationManager::class.java)

        val monitorChannel = NotificationChannel(
            CHANNEL_ID,
            "App Lock Monitor",
            NotificationManager.IMPORTANCE_MIN
        ).apply {
            description = "Monitors app launches to protect locked apps"
            setShowBadge(false)
        }
        nm.createNotificationChannel(monitorChannel)

        val lockChannel = NotificationChannel(
            LOCK_CHANNEL_ID,
            "App Lock Alert",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Shows lock screen when a protected app is opened"
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        nm.createNotificationChannel(lockChannel)
    }

    private fun buildNotification(): Notification {
        val tapIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("App Locker Active")
            .setContentText("Your apps are protected")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
}
