import 'package:flutter/material.dart';
import 'package:cardly/presentation/widgets/business_card/card_background.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/screens/profile/widgets/section_label.dart';

/// Widget for selecting background patterns/gradients for business cards
class BackgroundPickerWidget extends StatelessWidget {
  final CardBackground selectedBackground;
  final List<CardBackground> backgrounds;
  final ValueChanged<CardBackground> onBackgroundSelected;
  final VoidCallback? onCustomBackgroundPressed;

  const BackgroundPickerWidget({
    super.key,
    required this.selectedBackground,
    required this.backgrounds,
    required this.onBackgroundSelected,
    this.onCustomBackgroundPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(text: 'CHANGE BACKGROUND'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Background options
              ...backgrounds.map((background) {
                final isSelected = background == selectedBackground;
                return _BackgroundOption(
                  background: background,
                  isSelected: isSelected,
                  onTap: () => onBackgroundSelected(background),
                );
              }),
              // Custom background picker button
              if (onCustomBackgroundPressed != null)
                _CustomPickerButton(
                  onTap: onCustomBackgroundPressed!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual background option widget
class _BackgroundOption extends StatelessWidget {
  final CardBackground background;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundOption({
    required this.background,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: background.build(),
        ),
      ),
    );
  }
}

/// Custom background picker button
class _CustomPickerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CustomPickerButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 2),
        ),
        child: const Icon(
          Icons.palette_outlined,
          color: AppColors.lightTextSecondary,
          size: 24,
        ),
      ),
    );
  }
}
