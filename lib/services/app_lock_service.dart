// Platform channel wrapper for controlling the native AppMonitorService
import 'package:flutter/services.dart';

class AppLockService {
  AppLockService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.app_lock/service');

  static Future<void> startService() async {
    await _channel.invokeMethod<bool>('startService');
  }

  static Future<void> stopService() async {
    await _channel.invokeMethod<bool>('stopService');
  }

  static Future<bool> isServiceRunning() async {
    final bool? running = await _channel.invokeMethod<bool>('isServiceRunning');
    return running ?? false;
  }

  static Future<bool> hasUsageStatsPermission() async {
    final bool? granted =
        await _channel.invokeMethod<bool>('hasUsageStatsPermission');
    return granted ?? false;
  }

  static Future<void> requestUsageStatsPermission() async {
    await _channel.invokeMethod<bool>('requestUsageStatsPermission');
  }

  static Future<bool> isBatteryOptimizationDisabled() async {
    final bool? disabled =
        await _channel.invokeMethod<bool>('isBatteryOptimizationDisabled');
    return disabled ?? false;
  }

  static Future<void> requestDisableBatteryOptimization() async {
    await _channel.invokeMethod<bool>('requestDisableBatteryOptimization');
  }

  static Future<bool> hasOverlayPermission() async {
    final bool? granted =
        await _channel.invokeMethod<bool>('hasOverlayPermission');
    return granted ?? false;
  }

  static Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod<bool>('requestOverlayPermission');
  }
}
