import 'package:flutter/material.dart';
import 'package:cardly/theme/spacing.dart';
import 'package:cardly/theme/typography.dart';

/// Action buttons for profile page (Edit and Save)
class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onSavePressed;

  const ProfileActionButtons({
    super.key,
    required this.onEditPressed,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Edit Card Button (Outlined)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onEditPressed,
            child: Text(
              'Edit Card',
              style: AppTextStyles.buttonSecondary(context).copyWith(
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Save Card Button (Filled)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onSavePressed,
            child: Text(
              'Save Card',
              style:
              AppTextStyles.buttonPrimary(context).copyWith(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
