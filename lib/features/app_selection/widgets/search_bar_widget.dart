// M3 SearchBar for filtering the installed apps list
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (BuildContext context, TextEditingValue value, _) {
          return SearchBar(
            controller: controller,
            hintText: AppStrings.searchApps,
            leading: const Padding(
              padding: EdgeInsets.only(left: AppDimensions.paddingSmall),
              child: Icon(Icons.search),
            ),
            trailing: value.text.isNotEmpty
                ? [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        onClear?.call();
                      },
                    ),
                  ]
                : null,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
            ),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
