// Entry point — runs the root App widget wrapped in Riverpod ProviderScope
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_complete') ?? false;
  runApp(ProviderScope(child: App(onboardingDone: onboardingDone)));
}
