// Tile showing background monitoring service status with a toggle switch
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class ServiceStatusTile extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool>? onToggle;

  const ServiceStatusTile({
    super.key,
    required this.isActive,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color dotColor =
        isActive ? AppColors.statusActive : AppColors.statusInactive;
    final String statusText =
        isActive ? AppStrings.protectionActive : AppStrings.protectionOff;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        secondary: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          statusText,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        value: isActive,
        onChanged: onToggle ?? (_) {},
      ),
    );
  }
}
