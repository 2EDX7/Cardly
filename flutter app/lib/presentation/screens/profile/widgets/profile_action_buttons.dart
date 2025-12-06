import 'package:flutter/material.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/l10n/app_localizations.dart';

/// Action buttons for profile page (Edit and Save)
class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditPressed;
  final VoidCallback? onSavePressed;

  const ProfileActionButtons({
    super.key,
    required this.onEditPressed,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // Edit Card Button (Outlined)
        SizedBox(
          width: double.infinity,
          // height: 56,
          child: OutlinedButton(
            onPressed: onEditPressed,
            child: Text(
              l10n.editCard,
              style: AppTextStyles.buttonSecondary(context).copyWith(
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Save Card Button (Filled)
        SizedBox(
          width: double.infinity,
          // height: 56,
          child: ElevatedButton(
            onPressed: onSavePressed,
            child: Text(
              l10n.save,
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
