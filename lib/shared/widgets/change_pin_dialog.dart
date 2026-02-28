import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../features/home/providers/profile_providers.dart';
import '../../features/onboarding/widgets/pin_setup_field.dart';
import '../../services/profile_repository.dart';

Future<bool> showChangePinDialog(
  BuildContext context, {
  required int profileId,
  required String profileName,
  required String profileEmoji,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangePinDialog(
      profileId: profileId,
      profileName: profileName,
      profileEmoji: profileEmoji,
    ),
  );
  return result ?? false;
}

class ChangePinDialog extends ConsumerStatefulWidget {
  final int profileId;
  final String profileName;
  final String profileEmoji;

  const ChangePinDialog({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.profileEmoji,
  });

  @override
  ConsumerState<ChangePinDialog> createState() => _ChangePinDialogState();
}

enum _ChangePinStep { verifyCurrent, enterNew, confirmNew }

class _ChangePinDialogState extends ConsumerState<ChangePinDialog> {
  _ChangePinStep _step = _ChangePinStep.verifyCurrent;
  String _enteredPin = '';
  String _newPin = '';
  bool _isError = false;
  bool _isVerifying = false;
  bool _isSuccess = false;

  String get _subtitle {
    switch (_step) {
      case _ChangePinStep.verifyCurrent:
        return AppStrings.enterCurrentPin;
      case _ChangePinStep.enterNew:
        return AppStrings.enterNewPin;
      case _ChangePinStep.confirmNew:
        return AppStrings.confirmNewPin;
    }
  }

  void _onKeyPressed(String key) {
    if (_isVerifying || _isError || _isSuccess || _enteredPin.length >= 4) {
      return;
    }
    setState(() => _enteredPin += key);
    if (_enteredPin.length == 4) {
      _handlePinComplete();
    }
  }

  void _onBackspace() {
    if (_isVerifying || _isError || _isSuccess || _enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _handlePinComplete() async {
    switch (_step) {
      case _ChangePinStep.verifyCurrent:
        await _verifyCurrentPin();
      case _ChangePinStep.enterNew:
        _newPin = _enteredPin;
        setState(() {
          _enteredPin = '';
          _step = _ChangePinStep.confirmNew;
        });
      case _ChangePinStep.confirmNew:
        await _confirmAndSave();
    }
  }

  Future<void> _verifyCurrentPin() async {
    setState(() => _isVerifying = true);
    final bool matched = await ProfileRepository().verifyPin(
      widget.profileId,
      _enteredPin,
    );
    if (!mounted) return;

    if (matched) {
      setState(() {
        _isVerifying = false;
        _enteredPin = '';
        _step = _ChangePinStep.enterNew;
      });
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

  Future<void> _confirmAndSave() async {
    if (_enteredPin != _newPin) {
      setState(() => _isError = true);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _isError = false;
        _enteredPin = '';
      });
      return;
    }

    setState(() => _isVerifying = true);
    await ref.read(profileListProvider.notifier).changePin(
          widget.profileId,
          _newPin,
        );
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _isSuccess = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    Navigator.pop(context, true);
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _subtitle,
                key: ValueKey(_step),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
                        _step == _ChangePinStep.confirmNew
                            ? AppStrings.newPinsDoNotMatch
                            : AppStrings.wrongPin,
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
