// Screen listing installed apps with checkboxes for locking selection
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/installed_app.dart';
import '../home/providers/profile_providers.dart';
import 'providers/installed_apps_provider.dart';
import 'widgets/app_tile.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/selected_count_bar.dart';

class AppSelectionScreen extends ConsumerStatefulWidget {
  final int profileId;

  const AppSelectionScreen({super.key, required this.profileId});

  @override
  ConsumerState<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends ConsumerState<AppSelectionScreen> {
  String _searchQuery = '';
  final Set<String> _selectedPackages = {};
  final TextEditingController _searchController = TextEditingController();
  bool _loadedExisting = false;
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingLockedApps() async {
    if (_loadedExisting) return;
    _loadedExisting = true;
    final List<String> existing = await ref
        .read(profileListProvider.notifier)
        .getLockedApps(widget.profileId);
    if (mounted) {
      setState(() => _selectedPackages.addAll(existing));
    }
  }

  List<InstalledApp> _filterApps(List<InstalledApp> apps) {
    if (_searchQuery.isEmpty) return apps;
    final String query = _searchQuery.toLowerCase();
    return apps.where((InstalledApp app) {
      return app.name.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<InstalledApp>> appsState =
        ref.watch(installedAppsProvider);

    appsState.whenData((_) => _loadExistingLockedApps());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectApps,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Choose apps to lock',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingSmall),
            SearchBarWidget(
              controller: _searchController,
              onChanged: (String value) {
                setState(() => _searchQuery = value);
              },
              onClear: () {
                setState(() => _searchQuery = '');
              },
            ),
          const SizedBox(height: AppDimensions.paddingSmall),
          SelectedCountBar(
            selectedCount: _selectedPackages.length,
            onClearAll: () {
              setState(() => _selectedPackages.clear());
            },
          ),
          Expanded(
            child: appsState.when(
              loading: () => _buildLoadingState(colorScheme),
              error: (Object error, _) =>
                  _buildErrorState(colorScheme, textTheme),
              data: (List<InstalledApp> apps) {
                final List<InstalledApp> filtered = _filterApps(apps);
                if (filtered.isEmpty) {
                  return _buildEmptyState(colorScheme, textTheme);
                }
                return _buildAppList(filtered, colorScheme);
              },
            ),
          ),
            _buildBottomSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            AppStrings.loadingApps,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colorScheme.error),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              AppStrings.failedToLoadApps,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            FilledButton.tonalIcon(
              onPressed: () {
                ref.read(installedAppsProvider.notifier).reload();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 56,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            AppStrings.noAppsFound,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppList(List<InstalledApp> apps, ColorScheme colorScheme) {
    final List<Color> containerColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: apps.length,
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingLarge),
      itemBuilder: (BuildContext context, int index) {
        final InstalledApp app = apps[index];
        final bool isSelected = _selectedPackages.contains(app.packageName);

        return AppTile(
          name: app.name,
          packageName: app.packageName,
          letter: app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
          avatarColor: containerColors[index % containerColors.length],
          isSelected: isSelected,
          icon: app.icon,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedPackages.remove(app.packageName);
              } else {
                _selectedPackages.add(app.packageName);
              }
            });
          },
        );
      },
    );
  }

  Future<void> _onSaveAndContinue() async {
    setState(() => _saving = true);
    await ref
        .read(profileListProvider.notifier)
        .saveLockedApps(widget.profileId, _selectedPackages.toList());
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildBottomSaveButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _onSaveAndContinue,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock),
            label: Text(_saving
                ? AppStrings.saving
                : AppStrings.saveAndContinue),
          ),
        ),
      ),
    );
  }
}
