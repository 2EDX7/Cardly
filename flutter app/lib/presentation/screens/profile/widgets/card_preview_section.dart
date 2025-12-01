import 'package:flutter/material.dart';
import 'package:cardly/presentation/widgets/business_card/business_card.dart';
import 'package:cardly/presentation/widgets/business_card/card_background.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/presentation/screens/profile/widgets/section_label.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "CARD PREVIEW" Label
        const SectionLabel(text: 'CARD PREVIEW'),
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
            'tap to flip',
            style: AppTextStyles.caption(context).copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
