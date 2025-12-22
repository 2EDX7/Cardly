import 'package:flutter/material.dart';
import 'package:cardly/presentation/widgets/business_card/business_card.dart';
import 'package:cardly/presentation/widgets/business_card/card_background.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/presentation/screens/profile/widgets/section_label.dart';
// import 'package:cardly/src/generated/l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget that displays the business card preview with flip functionality
class CardPreviewSection extends StatelessWidget {
  final String name;
  // final String logoText;
  final String organization;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String about;
  final String website;
  final CardBackground background;
  final Color textColor;
  final VoidCallback onCardTap;
  final String? shareableId;

  const CardPreviewSection({
    super.key,
    required this.name,
    // required this.logoText,
    required this.organization,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    required this.about,
    required this.website,
    required this.background,
    required this.textColor,
    required this.onCardTap,
    this.shareableId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "CARD PREVIEW" Label
        SectionLabel(text: l10n.cardPreview),
        const SizedBox(height: AppSpacing.md),

        // Business Card with Flip Animation
        Center(
          child: GestureDetector(
            onTap: onCardTap,
            child: BusinessCard(
              name: name,
              // logoText: logoText,
              organization: organization,
              jobTitle: jobTitle,
              email: email,
              phone: phone,
              location: location,
              about: about,
              website: website,
              background: background,
              textColor: textColor,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // "tap to flip" text
        Center(
          child: Text(
            l10n.tapToFlip,
            style: AppTextStyles.caption(context).copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        if (shareableId != null && shareableId!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              child: SelectableText(
                // Make it copyable
                'ID: $shareableId',
                style: AppTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
