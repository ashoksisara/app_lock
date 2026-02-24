// PIN dots display and number pad for PIN entry steps
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class PinDots extends StatelessWidget {
  final int filledCount;
  final bool isError;

  const PinDots({
    super.key,
    required this.filledCount,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color fillColor =
        isError ? colorScheme.error : colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (int index) {
        final bool isFilled = index < filledCount;

        return Padding(
          padding: EdgeInsets.only(
            right: index < 3 ? AppDimensions.paddingMedium : 0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: AppDimensions.pinDotSize,
            height: AppDimensions.pinDotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? fillColor : Colors.transparent,
              border: isFilled
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant,
                      width: 2,
                    ),
            ),
          ),
        );
      }),
    );
  }
}

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: AppDimensions.borderRadiusMedium),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: AppDimensions.borderRadiusMedium),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: AppDimensions.borderRadiusMedium),
        _buildRow(context, ['backspace', '0', '']),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((String key) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          child: _buildKey(context, key),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (key.isEmpty) {
      return SizedBox(
        width: AppDimensions.numberPadButtonSize,
        height: AppDimensions.numberPadButtonSize,
      );
    }

    final bool isBackspace = key == 'backspace';

    return SizedBox(
      width: AppDimensions.numberPadButtonSize,
      height: AppDimensions.numberPadButtonSize,
      child: Material(
        color: isBackspace
            ? Colors.transparent
            : colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace_outlined,
                    color: colorScheme.onSurfaceVariant,
                  )
                : Text(
                    key,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
