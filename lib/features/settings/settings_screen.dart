// Settings screen — grouped sections for profiles, security, protection, appearance, about, and danger zone
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/relock_timing_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/home/providers/profile_providers.dart';
import '../../services/app_lock_service.dart';
import 'widgets/danger_zone_tile.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  bool _useBiometrics = true;
  bool _intruderDetection = false;
  bool _serviceRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadServiceState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadServiceState();
    }
  }

  Future<void> _loadServiceState() async {
    try {
      final bool running = await AppLockService.isServiceRunning();
      if (mounted) setState(() => _serviceRunning = running);
    } catch (_) {}
  }

  Future<void> _toggleService(bool value) async {
    try {
      await AppLockService.setServiceEnabled(enabled: value);
      if (mounted) setState(() => _serviceRunning = value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(AppStrings.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            _buildSecuritySection(),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildProtectionSection(),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildAppearanceSection(),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildAboutSection(),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildDangerZone(colorScheme, textTheme),
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return SettingsSection(
      title: AppStrings.sectionSecurity,
      children: [
        SettingsTile(
          icon: _serviceRunning
              ? Icons.verified_user
              : Icons.shield_outlined,
          title: _serviceRunning
              ? AppStrings.serviceRunning
              : AppStrings.activateProtection,
          subtitle: _serviceRunning
              ? AppStrings.protectionActive
              : AppStrings.serviceNotRunning,
          toggleValue: _serviceRunning,
          onToggleChanged: _toggleService,
        ),
        SettingsTile(
          icon: Icons.fingerprint,
          title: AppStrings.useBiometrics,
          toggleValue: _useBiometrics,
          onToggleChanged: (bool value) {
            setState(() => _useBiometrics = value);
          },
        ),
        SettingsTile(
          icon: Icons.camera_alt_outlined,
          title: AppStrings.intruderDetection,
          subtitle: AppStrings.intruderDetectionSub,
          toggleValue: _intruderDetection,
          onToggleChanged: (bool value) {
            setState(() => _intruderDetection = value);
          },
        ),
      ],
    );
  }

  Widget _buildProtectionSection() {
    final int currentMs = ref.watch(relockTimingProvider);
    final String label = relockOptions[currentMs] ?? AppStrings.relock1Min;

    return SettingsSection(
      title: AppStrings.sectionProtection,
      children: [
        SettingsTile(
          icon: Icons.timer_outlined,
          title: AppStrings.relockTiming,
          subtitle: label,
          onTap: () => _showRelockTimingSheet(currentMs),
        ),
      ],
    );
  }

  void _showRelockTimingSheet(int currentMs) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.56,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (BuildContext context, ScrollController scrollController) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(
                      AppStrings.relockTiming,
                      style:
                          Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      shrinkWrap: true,
                      children: relockOptions.entries
                          .map((MapEntry<int, String> entry) {
                        return RadioListTile<int>(
                          title: Text(entry.value),
                          value: entry.key,
                          groupValue: currentMs,
                          onChanged: (int? value) {
                            if (value != null) {
                              ref
                                  .read(relockTimingProvider.notifier)
                                  .setTiming(value);
                              Navigator.pop(sheetContext);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection() {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final bool isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return SettingsSection(
      title: AppStrings.sectionAppearance,
      children: [
        SettingsTile(
          icon: isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
          title: AppStrings.darkMode,
          toggleValue: isDark,
          onToggleChanged: (bool value) {
            ref.read(themeModeProvider.notifier).setDarkMode(value);
          },
        ),
        SettingsTile(
          icon: Icons.language,
          title: AppStrings.appLanguage,
          subtitle: 'English',
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: AppStrings.sectionAbout,
      children: [
        SettingsTile(
          icon: Icons.info_outline,
          title: AppStrings.appVersion,
          trailingText: 'v1.0.0',
          showArrow: false,
        ),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: AppStrings.privacyPolicy,
        ),
        SettingsTile(
          icon: Icons.star_outline,
          title: AppStrings.rateApp,
        ),
      ],
    );
  }

  Widget _buildDangerZone(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.paddingMedium,
            bottom: AppDimensions.paddingSmall,
          ),
          child: Text(
            AppStrings.sectionDangerZone,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
        Card(
          color: colorScheme.errorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: Column(
            children: [
              DangerZoneTile(
                icon: Icons.restart_alt,
                title: AppStrings.resetAllProfiles,
                subtitle: AppStrings.resetAllProfilesSub,
                onTap: () => _confirmResetAll(colorScheme),
              ),
              DangerZoneTile(
                icon: Icons.lock_open,
                title: AppStrings.uninstallProtection,
                subtitle: AppStrings.uninstallProtectionSub,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmResetAll(ColorScheme colorScheme) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.warning_rounded, color: colorScheme.error, size: 32),
          title: const Text(AppStrings.resetAllProfiles),
          content: const Text(AppStrings.resetAllConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(profileListProvider.notifier).resetAll();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(AppStrings.resetAllDone),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.paddingSmall),
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text(AppStrings.resetAllProfiles),
            ),
          ],
        );
      },
    );
  }
}
