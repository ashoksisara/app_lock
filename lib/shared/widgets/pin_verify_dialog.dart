// Reusable PIN verification dialog — gates profile actions behind the profile's own PIN
import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../features/onboarding/widgets/pin_setup_field.dart';
import '../../services/profile_repository.dart';

Future<bool> showPinVerifyDialog(
  BuildContext context, {
  required int profileId,
  required String profileName,
  required String profileEmoji,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PinVerifyDialog(
      profileId: profileId,
      profileName: profileName,
      profileEmoji: profileEmoji,
    ),
  );
  return result ?? false;
}

class PinVerifyDialog extends StatefulWidget {
  final int profileId;
  final String profileName;
  final String profileEmoji;

  const PinVerifyDialog({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.profileEmoji,
  });

  @override
  State<PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends State<PinVerifyDialog> {
  String _enteredPin = '';
  bool _isError = false;
  bool _isVerifying = false;
  bool _isSuccess = false;

  void _onKeyPressed(String key) {
    if (_isVerifying || _isError || _isSuccess || _enteredPin.length >= 4) {
      return;
    }

    setState(() => _enteredPin += key);

    if (_enteredPin.length == 4) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_isVerifying || _isError || _isSuccess || _enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _isVerifying = true);

    final bool matched = await ProfileRepository().verifyPin(
      widget.profileId,
      _enteredPin,
    );

    if (!mounted) return;

    if (matched) {
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isError = true;
      _isVerifying = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isError = false;
      _enteredPin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool inputDisabled = _isVerifying || _isError || _isSuccess;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSuccess
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isSuccess
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('check'),
                          color: colorScheme.onPrimary,
                          size: 32,
                        )
                      : Text(
                          widget.profileEmoji,
                          key: const ValueKey('emoji'),
                          style: const TextStyle(fontSize: 28),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              widget.profileName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall / 2),
            Text(
              AppStrings.enterPinToContinue,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            PinDots(
              filledCount: _enteredPin.length,
              isError: _isError,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            SizedBox(
              height: 20,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isError
                    ? Text(
                        AppStrings.wrongPin,
                        key: const ValueKey('error'),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            IgnorePointer(
              ignoring: inputDisabled,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: inputDisabled ? 0.4 : 1.0,
                child: NumberPad(
                  onKeyPressed: _onKeyPressed,
                  onBackspace: _onBackspace,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextButton(
              onPressed: inputDisabled
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
