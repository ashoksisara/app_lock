// Home screen — displays profile cards, permission warnings, and add-profile FAB
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_profile.dart';
import '../../services/app_lock_service.dart';
import '../../shared/widgets/change_pin_dialog.dart';
import '../../shared/widgets/pin_verify_dialog.dart';
import 'providers/profile_providers.dart';
import 'widgets/profile_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  bool _hasAccessibilityPermission = false;
  bool _hasOverlayPermission = false;
  bool _checkingStatus = true;
  bool _permissionDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    try {
      final bool accessibility =
          await AppLockService.isAccessibilityServiceEnabled();
      final bool overlay = await AppLockService.hasOverlayPermission();
      if (mounted) {
        setState(() {
          _hasAccessibilityPermission = accessibility;
          _hasOverlayPermission = overlay;
          _checkingStatus = false;
        });
        if ((!accessibility || !overlay) && !_permissionDialogShown) {
          _permissionDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showPermissionSheet();
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _checkingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<UserProfile>> profileState =
        ref.watch(profileListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.settingsTooltip,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPermissionWarning(colorScheme, textTheme),
          Expanded(
            child: profileState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _buildErrorState(
                context,
                colorScheme,
                textTheme,
                onRetry: () => ref.invalidate(profileListProvider),
              ),
              data: (List<UserProfile> profiles) => profiles.isEmpty
                  ? _buildEmptyState(colorScheme, textTheme)
                  : _buildProfileList(context, ref, colorScheme, textTheme, profiles),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.profileSetup);
        },
        icon: const Icon(Icons.person_add),
        label: const Text(AppStrings.addProfile),
      ),
    );
  }

  // --- Permission Sheet ---

  void _showPermissionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _PermissionSheet(
        hasAccessibilityPermission: _hasAccessibilityPermission,
        hasOverlayPermission: _hasOverlayPermission,
        onDone: () async {
          Navigator.pop(context);
          await AppLockService.setServiceEnabled(enabled: true);
          _checkStatus();
        },
      ),
    );
  }

  // --- Permission Warning Banner ---

  Widget _buildPermissionWarning(ColorScheme colorScheme, TextTheme textTheme) {
    if (_checkingStatus || (_hasAccessibilityPermission && _hasOverlayPermission)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
        0,
      ),
      child: Card(
        color: colorScheme.errorContainer,
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _permissionDialogShown = false;
            _showPermissionSheet();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Text(
                    AppStrings.permissionsRequired,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onErrorContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Text(
              AppStrings.noProfilesTitle,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              AppStrings.noProfilesDescription,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Something went wrong',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<UserProfile> profiles,
  ) {
    final List<Color> cardColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    final Map<int, int> lockedCounts =
        ref.watch(lockedAppsCountProvider).value ?? {};

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge).copyWith(
        bottom: AppDimensions.paddingLarge + 80,
      ),
      itemCount: profiles.length,
      itemBuilder: (BuildContext context, int index) {
        final UserProfile profile = profiles[index];
        final int count = lockedCounts[profile.id] ?? 0;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < profiles.length - 1
                ? AppDimensions.paddingMedium
                : 0,
          ),
          child: ProfileCard(
            emoji: profile.emoji,
            name: profile.name,
            lockedAppsCount: count,
            backgroundColor: cardColors[index % cardColors.length],
            onTap: () => _showProfileSheet(context, ref, profile, colorScheme),
          ),
        );
      },
    );
  }

  void _showProfileSheet(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    ColorScheme colorScheme,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String formattedDate =
        '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}';

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    profile.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  profile.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Text(
                  '${AppStrings.createdOn} $formattedDate',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text(AppStrings.editProfileOption),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final bool verified = await showPinVerifyDialog(
                      context,
                      profileId: profile.id!,
                      profileName: profile.name,
                      profileEmoji: profile.emoji,
                    );
                    if (!verified || !context.mounted) return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profileSetup,
                      arguments: {
                        'id': profile.id,
                        'name': profile.name,
                        'emoji': profile.emoji,
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text(AppStrings.changePinOption),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final bool changed = await showChangePinDialog(
                      context,
                      profileId: profile.id!,
                      profileName: profile.name,
                      profileEmoji: profile.emoji,
                    );
                    if (!changed || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(AppStrings.pinChanged),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.paddingSmall,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.apps),
                  title: const Text(AppStrings.selectAppsFor),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final bool verified = await showPinVerifyDialog(
                      context,
                      profileId: profile.id!,
                      profileName: profile.name,
                      profileEmoji: profile.emoji,
                    );
                    if (!verified || !context.mounted) return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.appSelection,
                      arguments: profile.id,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    AppStrings.deleteProfile,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final bool verified = await showPinVerifyDialog(
                      context,
                      profileId: profile.id!,
                      profileName: profile.name,
                      profileEmoji: profile.emoji,
                    );
                    if (!verified || !context.mounted) return;
                    _confirmDelete(context, ref, profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.deleteProfile),
          content: Text(AppStrings.deleteProfileConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (profile.id != null) {
                  await ref
                      .read(profileListProvider.notifier)
                      .deleteProfile(profile.id!);
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(AppStrings.profileDeleted),
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
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
  }
}

class _PermissionSheet extends StatefulWidget {
  const _PermissionSheet({
    required this.hasAccessibilityPermission,
    required this.hasOverlayPermission,
    required this.onDone,
  });

  final bool hasAccessibilityPermission;
  final bool hasOverlayPermission;
  final VoidCallback onDone;

  @override
  State<_PermissionSheet> createState() => _PermissionSheetState();
}

class _PermissionSheetState extends State<_PermissionSheet>
    with WidgetsBindingObserver {
  late bool _accessibilityGranted;
  late bool _overlayGranted;

  @override
  void initState() {
    super.initState();
    _accessibilityGranted = widget.hasAccessibilityPermission;
    _overlayGranted = widget.hasOverlayPermission;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final bool accessibility =
        await AppLockService.isAccessibilityServiceEnabled();
    final bool overlay = await AppLockService.hasOverlayPermission();
    if (mounted) {
      setState(() {
        _accessibilityGranted = accessibility;
        _overlayGranted = overlay;
      });
    }
  }

  bool get _allGranted => _accessibilityGranted && _overlayGranted;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: _allGranted,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _allGranted
                    ? colorScheme.primaryContainer
                    : colorScheme.errorContainer,
              ),
              child: Icon(
                _allGranted ? Icons.check_rounded : Icons.security_rounded,
                size: 28,
                color: _allGranted
                    ? colorScheme.primary
                    : colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.permissionsRequired,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.permissionsDialogDescription,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _PermissionTile(
              step: '1',
              icon: Icons.accessibility_new_rounded,
              title: AppStrings.accessibilityTitle,
              subtitle: AppStrings.accessibilityShort,
              isGranted: _accessibilityGranted,
              onTap: _accessibilityGranted
                  ? null
                  : () => AppLockService.requestAccessibilityPermission(),
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              step: '2',
              icon: Icons.layers_rounded,
              title: AppStrings.overlayTitle,
              subtitle: AppStrings.overlayShort,
              isGranted: _overlayGranted,
              onTap: _overlayGranted
                  ? null
                  : () => AppLockService.requestOverlayPermission(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _allGranted ? widget.onDone : null,
                icon: Icon(
                  _allGranted ? Icons.check_rounded : Icons.lock_outline,
                ),
                label: Text(
                  _allGranted
                      ? AppStrings.continueText
                      : AppStrings.permissionsRequired,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onTap,
  });

  final String step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: isGranted
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isGranted
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHigh,
                ),
                child: Center(
                  child: isGranted
                      ? Icon(Icons.check_rounded,
                          size: 18, color: colorScheme.onPrimary)
                      : Text(
                          step,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isGranted
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isGranted)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.check_circle_rounded,
                                color: colorScheme.primary, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!isGranted) ...[
                      const SizedBox(height: 10),
                      FilledButton.tonal(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(AppStrings.grantPermission),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
