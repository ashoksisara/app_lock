import 'package:flutter/services.dart';

class AppLockService {
  AppLockService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.app_lock/service');

  static Future<bool> isAccessibilityServiceEnabled() async {
    final bool? enabled =
        await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
    return enabled ?? false;
  }

  static Future<void> requestAccessibilityPermission() async {
    await _channel.invokeMethod<bool>('requestAccessibilityPermission');
  }

  static Future<bool> isServiceRunning() async {
    final bool? running =
        await _channel.invokeMethod<bool>('isServiceRunning');
    return running ?? false;
  }

  static Future<void> setServiceEnabled({required bool enabled}) async {
    await _channel
        .invokeMethod<bool>('setServiceEnabled', {'enabled': enabled});
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
