// Larger number pad for the lock screen with backspace and cancel keys
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class LockNumberPad extends StatelessWidget {
  const LockNumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 10),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 10),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 10),
        _buildRow(context, ['backspace', '0', 'cancel']),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: _buildKey(context, key),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isBackspace = key == 'backspace';
    final isCancel = key == 'cancel';
    final isSpecial = isBackspace || isCancel;

    return SizedBox(
      width: AppDimensions.lockNumberPadButtonSize,
      height: AppDimensions.lockNumberPadButtonSize,
      child: Material(
        color: isSpecial ? Colors.transparent : colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace_outlined,
                    size: 28,
                    color: colorScheme.onSurfaceVariant,
                  )
                : isCancel
                    ? Tooltip(
                        message: AppStrings.goBack,
                        child: Icon(
                          Icons.close,
                          size: 28,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Text(
                        key,
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
