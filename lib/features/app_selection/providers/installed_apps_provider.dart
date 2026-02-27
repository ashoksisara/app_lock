// Riverpod provider for fetching and caching installed apps from the device
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

import '../../../models/installed_app.dart';

final installedAppsProvider =
    AsyncNotifierProvider<InstalledAppsNotifier, List<InstalledApp>>(
  InstalledAppsNotifier.new,
);

class InstalledAppsNotifier extends AsyncNotifier<List<InstalledApp>> {
  @override
  Future<List<InstalledApp>> build() async {
    return _fetchApps();
  }

  Future<List<InstalledApp>> _fetchApps() async {
    try {
      final List<AppInfo> appInfos = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        withIcon: true,
      );

      final List<InstalledApp> apps = appInfos.map((AppInfo info) {
        return InstalledApp(
          name: info.name,
          packageName: info.packageName,
          icon: info.icon != null ? Uint8List.fromList(info.icon!) : null,
        );
      }).toList();

      apps.sort(
        (InstalledApp a, InstalledApp b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      debugPrint('InstalledAppsProvider: fetched ${apps.length} apps');

      return apps;
    } catch (error) {
      debugPrint('Failed to fetch installed apps: $error');
      rethrow;
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchApps);
  }
}
