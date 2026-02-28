// Profile setup wizard — step 1: avatar & name, step 2: set PIN, step 3: confirm PIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../home/providers/profile_providers.dart';
import 'widgets/emoji_avatar_picker.dart';
import 'widgets/pin_setup_field.dart';
import 'widgets/step_indicator.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final int? editProfileId;
  final String? editName;
  final String? editEmoji;

  const ProfileSetupScreen({
    super.key,
    this.editProfileId,
    this.editName,
    this.editEmoji,
  });

  bool get isEditMode => editProfileId != null;

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _currentStep = 1;
  String _selectedEmoji = '🧑';
  final TextEditingController _nameController = TextEditingController();
  String _nameError = '';
  String _pin = '';
  String _confirmPin = '';
  bool _pinMismatch = false;

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;
  bool get _isPinComplete => _pin.length == 4;
  bool get _isConfirmPinComplete => _confirmPin.length == 4;

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      _pinMismatch = false;
    });
  }

  Future<void> _handleNext() async {
    switch (_currentStep) {
      case 1:
        if (!_isNameValid) {
          setState(() => _nameError = AppStrings.profileNameRequired);
          return;
        }
        if (_isEditMode) {
          await _saveEdit();
          return;
        }
        _goToStep(2);
      case 2:
        if (_isPinComplete) {
          _goToStep(3);
        }
      case 3:
        if (_isConfirmPinComplete) {
          await _validateAndSave();
        }
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        if (_currentStep == 3) {
          _confirmPin = '';
          _pinMismatch = false;
        } else if (_currentStep == 2) {
          _pin = '';
        }
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _onPinKeyPressed(String key) {
    setState(() {
      if (_currentStep == 2 && _pin.length < 4) {
        _pin += key;
      } else if (_currentStep == 3 && _confirmPin.length < 4) {
        _pinMismatch = false;
        _confirmPin += key;
      }
    });
  }

  void _onPinBackspace() {
    setState(() {
      if (_currentStep == 2 && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_currentStep == 3 && _confirmPin.isNotEmpty) {
        _pinMismatch = false;
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  bool _isSaving = false;

  Future<void> _validateAndSave() async {
    if (_pin != _confirmPin) {
      setState(() {
        _pinMismatch = true;
        _confirmPin = '';
      });
      return;
    }

    setState(() => _isSaving = true);

    try {
      final int profileId =
          await ref.read(profileListProvider.notifier).addProfile(
                name: _nameController.text.trim(),
                emoji: _selectedEmoji,
                pin: _pin,
              );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.profileCreated),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
          ),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.appSelection,
        (Route<dynamic> route) => false,
        arguments: profileId,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileListProvider.notifier).updateProfile(
            id: widget.editProfileId!,
            name: _nameController.text.trim(),
            emoji: _selectedEmoji,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.profileUpdated),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool get _isEditMode => widget.isEditMode;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _selectedEmoji = widget.editEmoji ?? '🧑';
      _nameController.text = widget.editName ?? '';
    }
    _nameController.addListener(() {
      if (_nameError.isNotEmpty && _nameController.text.trim().isNotEmpty) {
        setState(() => _nameError = '');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          title: Text(_isEditMode ? AppStrings.editProfile : AppStrings.newProfile),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (!_isEditMode) StepIndicator(currentStep: _currentStep),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _buildCurrentStep(context),
                  ),
                ),
              ),
              _buildBottomButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 2:
        return _buildStepTwo(context);
      case 3:
        return _buildStepThree(context);
      default:
        return _buildStepOne(context);
    }
  }

  Widget _buildStepOne(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmojiAvatarPicker(
              emoji: _selectedEmoji,
              onEmojiSelected: (String emoji) {
                setState(() => _selectedEmoji = emoji);
              },
            ),
            const SizedBox(height: AppDimensions.paddingLarge * 2),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: AppStrings.profileName,
                hintText: AppStrings.profileNameHint,
                prefixIcon: const Icon(Icons.person),
                errorText: _nameError.isNotEmpty ? _nameError : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMedium,
                  ),
                ),
              ),
              maxLength: 20,
              buildCounter: (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return Text(
                  '$currentLength/$maxLength',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.setYourPIN,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.setYourPINSub,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        PinDots(filledCount: _pin.length),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        NumberPad(
          onKeyPressed: _onPinKeyPressed,
          onBackspace: _onPinBackspace,
        ),
      ],
    );
  }

  Widget _buildStepThree(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.confirmYourPIN,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.confirmYourPINSub,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        PinDots(
          filledCount: _confirmPin.length,
          isError: _pinMismatch,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _pinMismatch ? 1.0 : 0.0,
          child: Text(
            AppStrings.pinsDoNotMatch,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        NumberPad(
          onKeyPressed: _onPinKeyPressed,
          onBackspace: _onPinBackspace,
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final bool isFinalStep = _isEditMode || _currentStep == 3;
    final bool isEnabled = !_isSaving &&
        switch (_currentStep) {
          1 => true,
          2 => _isPinComplete,
          3 => _isConfirmPinComplete,
          _ => false,
        };

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isEnabled ? _handleNext : null,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(isFinalStep ? Icons.check : Icons.arrow_forward),
          label: Text(isFinalStep ? AppStrings.saveProfile : AppStrings.next),
        ),
      ),
    );
  }
}
