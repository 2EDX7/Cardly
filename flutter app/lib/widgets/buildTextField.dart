import 'package:flutter/material.dart';
import 'package:cardly/theme/spacing.dart';
import 'package:cardly/theme/typography.dart';

Widget buildTextField(BuildContext context, String hint, TextEditingController controller) {
  final bg = Theme.of(context).colorScheme.surface;
  final textColor = Theme.of(context).colorScheme.onSurface;

  return Container(
    margin: EdgeInsets.only(bottom: AppSpacing.sm),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      style: AppTextStyles.body(context).copyWith(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall(context).copyWith(color: textColor.withAlpha(160)),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    ),
  );
}