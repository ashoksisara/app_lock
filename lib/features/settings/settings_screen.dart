// Settings screen — grouped sections for profiles, security, protection, appearance, about, and danger zone
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../services/app_lock_service.dart';
import 'widgets/danger_zone_tile.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useBiometrics = true;
  bool _intruderDetection = false;
  bool _lockOnScreenOff = true;
  bool _darkMode = false;
  bool _serviceRunning = false;

  @override
  void initState() {
    super.initState();
    _loadServiceState();
  }

  Future<void> _loadServiceState() async {
    try {
      final bool running = await AppLockService.isServiceRunning();
      if (mounted) setState(() => _serviceRunning = running);
    } catch (_) {}
  }

  Future<void> _toggleService(bool value) async {
    try {
      if (value) {
        await AppLockService.startService();
      } else {
        await AppLockService.stopService();
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('service_enabled', value);
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
            _buildProfilesSection(),
            const SizedBox(height: AppDimensions.paddingLarge),
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

  Widget _buildProfilesSection() {
    return SettingsSection(
      title: AppStrings.sectionProfiles,
      children: [
        SettingsTile(
          icon: Icons.people_outline,
          title: AppStrings.manageProfiles,
        ),
        SettingsTile(
          icon: Icons.swap_horiz,
          title: AppStrings.switchProfile,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return SettingsSection(
      title: AppStrings.sectionSecurity,
      children: [
        SettingsTile(
          icon: Icons.pin,
          title: AppStrings.changePIN,
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
    return SettingsSection(
      title: AppStrings.sectionProtection,
      children: [
        SettingsTile(
          icon: Icons.timer_outlined,
          title: AppStrings.relockTiming,
          subtitle: '30 seconds',
        ),
        SettingsTile(
          icon: Icons.screen_lock_portrait,
          title: AppStrings.lockOnScreenOff,
          toggleValue: _lockOnScreenOff,
          onToggleChanged: (bool value) {
            setState(() => _lockOnScreenOff = value);
          },
        ),
        SettingsTile(
          icon: Icons.miscellaneous_services,
          title: AppStrings.backgroundService,
          subtitle: _serviceRunning ? 'Running' : 'Stopped',
          toggleValue: _serviceRunning,
          onToggleChanged: _toggleService,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return SettingsSection(
      title: AppStrings.sectionAppearance,
      children: [
        SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: AppStrings.darkMode,
          toggleValue: _darkMode,
          onToggleChanged: (bool value) {
            setState(() => _darkMode = value);
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
}
