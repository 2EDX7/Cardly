import 'package:flutter/material.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/screens/profile/widgets/section_label.dart';
import 'package:cardly/l10n/app_localizations.dart';

/// Widget for selecting font colors for business cards
class ColorPickerWidget extends StatelessWidget {
  final Color selectedColor;
  final List<Color> colors;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback? onCustomColorPressed;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.colors,
    required this.onColorSelected,
    this.onCustomColorPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: l10n.changeFontColor),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length + (onCustomColorPressed != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < colors.length) {
                final color = colors[index];
                final isSelected = color == selectedColor;
                return Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: _ColorOption(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => onColorSelected(color),
                  ),
                );
              } else {
                // Custom color picker button
                return Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: _CustomPickerButton(
                    onTap: onCustomColorPressed!,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Individual color option widget
class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
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
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : color == Colors.white
                    ? AppColors.divider
                    : Colors.transparent,
            width: isSelected ? 3 : (color == Colors.white ? 1 : 0),
          ),
        ),
      ),
    );
  }
}

/// Custom color picker button
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
