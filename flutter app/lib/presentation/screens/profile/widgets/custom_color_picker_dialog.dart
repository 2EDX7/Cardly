import 'package:flutter/material.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import '../../../../src/generated/l10n/app_localizations.dart';

/// Custom color picker dialog with RGB sliders
class CustomColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const CustomColorPickerDialog({
    super.key,
    required this.initialColor,
  });

  @override
  State<CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<CustomColorPickerDialog> {
  late double _red;
  late double _green;
  late double _blue;

  @override
  void initState() {
    super.initState();
    final int value = widget.initialColor.value;
    _red = ((value >> 16) & 0xFF).toDouble();
    _green = ((value >> 8) & 0xFF).toDouble();
    _blue = (value & 0xFF).toDouble();
  }

  Color get _currentColor => Color.fromRGBO(
        _red.toInt(),
        _green.toInt(),
        _blue.toInt(),
        1,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              l10n.chooseCustomColor,
              style: AppTextStyles.heading3(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color Preview
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // RGB Sliders
            _buildColorSlider(
              label: l10n.red,
              value: _red,
              color: Colors.red,
              onChanged: (value) {
                setState(() {
                  _red = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.md),

            _buildColorSlider(
              label: l10n.green,
              value: _green,
              color: Colors.green,
              onChanged: (value) {
                setState(() {
                  _green = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.md),

            _buildColorSlider(
              label: l10n.blue,
              value: _blue,
              color: Colors.blue,
              onChanged: (value) {
                setState(() {
                  _blue = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Predefined color options
            Text(
              'Quick Colors',
              style: AppTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildQuickColors(),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_currentColor);
                    },
                    child: Text(l10n.apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: AppTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickColors() {
    final quickColors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickColors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _red = color.red.toDouble();
              _green = color.green.toDouble();
              _blue = color.blue.toDouble();
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color == Colors.white
                    ? AppColors.divider
                    : Colors.transparent,
                width: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Helper function to show the custom color picker dialog
Future<Color?> showCustomColorPicker(
  BuildContext context, {
  required Color initialColor,
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) => CustomColorPickerDialog(
      initialColor: initialColor,
    ),
  );
}
