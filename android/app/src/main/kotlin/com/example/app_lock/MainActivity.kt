package com.example.app_lock

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.example.app_lock/service"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        val intent = Intent(this, AppMonitorService::class.java)
                        startForegroundService(intent)
                        result.success(true)
                    }
                    "stopService" -> {
                        val intent = Intent(this, AppMonitorService::class.java)
                        stopService(intent)
                        result.success(true)
                    }
                    "isServiceRunning" -> {
                        result.success(AppMonitorService.isRunning)
                    }
                    "hasUsageStatsPermission" -> {
                        result.success(UsageStatsHelper.hasPermission(this))
                    }
                    "requestUsageStatsPermission" -> {
                        UsageStatsHelper.openPermissionSettings(this)
                        result.success(true)
                    }
                    "isBatteryOptimizationDisabled" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "requestDisableBatteryOptimization" -> {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(true)
                    }
                    "hasOverlayPermission" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "requestOverlayPermission" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
