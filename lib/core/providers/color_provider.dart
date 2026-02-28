import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';

const String _kSeedColorKey = 'seed_color';

const List<Color> seedColorOptions = [
  Color(0xFF6750A4), // Purple (default)
  Color(0xFF3F51B5), // Indigo
  Color(0xFF1976D2), // Blue
  Color(0xFF0097A7), // Cyan
  Color(0xFF009688), // Teal
  Color(0xFF388E3C), // Green
  Color(0xFF689F38), // Lime
  Color(0xFFF9A825), // Yellow
  Color(0xFFEF6C00), // Orange
  Color(0xFFD32F2F), // Red
  Color(0xFFC2185B), // Pink
  Color(0xFF8E24AA), // Deep Purple
  Color(0xFF795548), // Brown
];

final seedColorProvider = NotifierProvider<SeedColorNotifier, Color>(
  SeedColorNotifier.new,
);

class SeedColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    _load();
    return AppColors.seedColor;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? saved = prefs.getInt(_kSeedColorKey);
    if (saved != null) {
      state = Color(saved);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeedColorKey, color.toARGB32());
  }
}
