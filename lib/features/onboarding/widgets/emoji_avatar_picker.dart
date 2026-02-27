// Large emoji avatar with an edit badge, tappable to trigger avatar selection
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

const List<String> _availableEmojis = [
  '🧑', '👩', '👨', '🧒', '👧', '👦',
  '🦊', '🐱', '🐶', '🐼', '🐨', '🦁',
  '🦄', '🐸', '🐵', '🐰', '🐻', '🐯',
  '🌟', '🔥', '💎', '🎯', '🎨', '🎭',
];

class EmojiAvatarPicker extends StatelessWidget {
  final String emoji;
  final ValueChanged<String>? onEmojiSelected;

  const EmojiAvatarPicker({
    super.key,
    required this.emoji,
    this.onEmojiSelected,
  });

  void _showEmojiPicker(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.chooseAvatar,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: AppDimensions.paddingSmall,
                  crossAxisSpacing: AppDimensions.paddingSmall,
                ),
                itemCount: _availableEmojis.length,
                itemBuilder: (BuildContext gridContext, int index) {
                  final String item = _availableEmojis[index];
                  final bool isSelected = item == emoji;

                  return GestureDetector(
                    onTap: () => Navigator.pop(sheetContext, item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        border: isSelected
                            ? Border.all(
                                color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(item, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
            ],
          ),
        );
      },
    ).then((String? selected) {
      if (selected != null) {
        onEmojiSelected?.call(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showEmojiPicker(context),
          child: SizedBox(
            width: AppDimensions.avatarSizeLarge,
            height: AppDimensions.avatarSizeLarge,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: AppDimensions.avatarSizeLarge / 2,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.primary,
                    child: Icon(
                      Icons.edit,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.tapToChangeAvatar,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
