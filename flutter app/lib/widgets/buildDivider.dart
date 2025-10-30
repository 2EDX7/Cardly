import 'package:flutter/material.dart';
import 'package:cardly/theme/spacing.dart';
import 'package:cardly/theme/typography.dart';

Widget buildDivider(BuildContext context) {
  final color = Theme.of(context).colorScheme.onBackground;
  return Row(
    children: [
      Expanded(child: Container(height: 1, color: Colors.black)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Text(
          'OR',
          style: AppTextStyles.heading3(context).copyWith(fontSize: 16, color: color),
        ),
      ),
      Expanded(child: Container(height: 1, color: Colors.black)),
    ],
  );
}