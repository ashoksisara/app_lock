package com.example.app_lock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_SERVICE_ENABLED = "flutter.service_enabled"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean(KEY_SERVICE_ENABLED, false)

        if (enabled) {
            Log.d(TAG, "Boot completed — starting AppMonitorService")
            val serviceIntent = Intent(context, AppMonitorService::class.java)
            context.startForegroundService(serviceIntent)
        } else {
            Log.d(TAG, "Boot completed — service not enabled, skipping")
        }
    }
}
