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

  void _onKeyPressed(String key) {
    if (_isVerifying || _isError || _enteredPin.length >= 4) return;

    setState(() => _enteredPin += key);

    if (_enteredPin.length == 4) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_isVerifying || _isError || _enteredPin.isEmpty) return;
    setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _isVerifying = true);

    final bool matched = await ProfileRepository().verifyPin(
      widget.profileId,
      _enteredPin,
    );

    if (!mounted) return;

    if (matched) {
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
            CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                widget.profileEmoji,
                style: const TextStyle(fontSize: 28),
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
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isError ? 1.0 : 0.0,
              child: Text(
                AppStrings.wrongPin,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            if (_isVerifying)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              NumberPad(
                onKeyPressed: _onKeyPressed,
                onBackspace: _onBackspace,
              ),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
