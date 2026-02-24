// M3 SearchBar for filtering the installed apps list
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      child: SearchBar(
        hintText: AppStrings.searchApps,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppDimensions.paddingSmall),
          child: Icon(Icons.search),
        ),
        trailing: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {},
          ),
        ],
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
        ),
        onChanged: (_) {},
      ),
    );
  }
}
