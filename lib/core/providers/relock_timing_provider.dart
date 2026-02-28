import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

const String _kRelockTimingKey = 'relock_timing_ms';
const int _kDefaultRelockMs = 60000;

const Map<int, String> relockOptions = {
  0: AppStrings.relockImmediately,
  60000: AppStrings.relock1Min,
  300000: AppStrings.relock5Min,
  900000: AppStrings.relock15Min,
  1800000: AppStrings.relock30Min,
  3600000: AppStrings.relock1Hour,
  -1: AppStrings.relockUntilScreenOff,
};

final relockTimingProvider = NotifierProvider<RelockTimingNotifier, int>(
  RelockTimingNotifier.new,
);

class RelockTimingNotifier extends Notifier<int> {
  @override
  int build() {
    _load();
    return _kDefaultRelockMs;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? saved = prefs.getInt(_kRelockTimingKey);
    if (saved != null && relockOptions.containsKey(saved)) {
      state = saved;
    }
  }

  Future<void> setTiming(int ms) async {
    state = ms;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRelockTimingKey, ms);
  }
}
