// PIN dot indicators for the lock screen with error shake support
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class LockPinDots extends StatelessWidget {
  final int filledCount;
  final bool isError;

  const LockPinDots({
    super.key,
    required this.filledCount,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = isError ? colorScheme.error : colorScheme.primary;

    // When isError is true, wrap this Row in a TweenAnimationBuilder<double>
    // to apply a horizontal offset shake (3 oscillations over 400ms).
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < filledCount;
        final dotSize = isFilled
            ? AppDimensions.lockPinDotSize + 2
            : AppDimensions.lockPinDotSize;

        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? 20 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? fillColor : Colors.transparent,
              border: isFilled
                  ? null
                  : Border.all(
                      color: colorScheme.outline,
                      width: 2,
                    ),
            ),
          ),
        );
      }),
    );
  }
}
