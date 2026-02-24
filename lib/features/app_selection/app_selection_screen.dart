// Screen listing installed apps with checkboxes for locking selection
import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/app_category_header.dart';
import 'widgets/app_tile.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/selected_count_bar.dart';

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              'Profile 1 \u2022 Choose apps to lock',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(AppStrings.done),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppDimensions.paddingSmall),
          const SearchBarWidget(),
          const SizedBox(height: AppDimensions.paddingSmall),
          SelectedCountBar(
            selectedCount: 3,
            onClearAll: () {},
          ),
          Expanded(
            child: ListView(
              children: [
                AppCategoryHeader(title: AppStrings.categorySocial),
                ..._buildCategoryApps(_socialApps, colorScheme),
                AppCategoryHeader(title: AppStrings.categoryGoogle),
                ..._buildCategoryApps(_googleApps, colorScheme),
                AppCategoryHeader(title: AppStrings.categoryEntertainment),
                ..._buildCategoryApps(_entertainmentApps, colorScheme),
                AppCategoryHeader(title: AppStrings.categoryOther),
                ..._buildCategoryApps(_otherApps, colorScheme),
                const SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
          _buildBottomSaveButton(context),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryApps(
    List<Map<String, dynamic>> apps,
    ColorScheme colorScheme,
  ) {
    final containerColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    return apps.asMap().entries.map((entry) {
      final app = entry.value;
      return AppTile(
        name: app['name'] as String,
        packageName: app['package'] as String,
        letter: app['letter'] as String,
        avatarColor: containerColors[entry.key % containerColors.length],
        isSelected: app['selected'] as bool,
        onTap: () {},
      );
    }).toList();
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
            onPressed: () {},
            icon: const Icon(Icons.lock),
            label: const Text(AppStrings.saveAndContinue),
          ),
        ),
      ),
    );
  }
}

const List<Map<String, dynamic>> _socialApps = [
  {'name': 'WhatsApp', 'package': 'com.whatsapp', 'letter': 'W', 'selected': true},
  {'name': 'Instagram', 'package': 'com.instagram.android', 'letter': 'I', 'selected': false},
  {'name': 'Telegram', 'package': 'org.telegram.messenger', 'letter': 'T', 'selected': true},
];

const List<Map<String, dynamic>> _googleApps = [
  {'name': 'Gmail', 'package': 'com.google.android.gm', 'letter': 'G', 'selected': true},
  {'name': 'Google Photos', 'package': 'com.google.android.apps.photos', 'letter': 'P', 'selected': false},
  {'name': 'Google Drive', 'package': 'com.google.android.apps.docs', 'letter': 'D', 'selected': false},
];

const List<Map<String, dynamic>> _entertainmentApps = [
  {'name': 'YouTube', 'package': 'com.google.android.youtube', 'letter': 'Y', 'selected': false},
  {'name': 'Spotify', 'package': 'com.spotify.music', 'letter': 'S', 'selected': false},
  {'name': 'Netflix', 'package': 'com.netflix.mediaclient', 'letter': 'N', 'selected': false},
];

const List<Map<String, dynamic>> _otherApps = [
  {'name': 'Gallery', 'package': 'com.android.gallery3d', 'letter': 'G', 'selected': false},
  {'name': 'File Manager', 'package': 'com.android.filemanager', 'letter': 'F', 'selected': false},
  {'name': 'Calculator', 'package': 'com.android.calculator2', 'letter': 'C', 'selected': false},
];
