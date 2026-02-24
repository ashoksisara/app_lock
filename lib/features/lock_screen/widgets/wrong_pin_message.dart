// Animated error message shown below PIN dots on incorrect entry
import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class WrongPinMessage extends StatelessWidget {
  final bool isVisible;

  const WrongPinMessage({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: Text(
        '${AppStrings.incorrectPIN} 2 ${AppStrings.attemptsRemaining}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
