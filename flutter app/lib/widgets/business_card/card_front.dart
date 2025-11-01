import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

class CardFront extends StatelessWidget {
  final String name;
  final String? logoText;
  final String? organization;
  final String? jobTitle;
  final String? email;
  final String? phone;
  final String? location;
  final Color textColor;
  final bool compactCard;

  const CardFront({
    super.key,
    required this.name,
    this.logoText,
    this.organization,
    this.jobTitle,
    this.email,
    this.phone,
    this.location,
    this.textColor = Colors.white,
    this.compactCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header with Name and Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.heading1(context).copyWith(
                  color: textColor,
                  fontSize: 26,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (logoText != null) ...[
              const SizedBox(width: AppSpacing.md),
              Text(
                logoText!,
                style: AppTextStyles.heading2(context).copyWith(
                  color: textColor.withOpacity(0.9),
                  fontSize: 28,
                ),
              ),
            ],
          ],
        ),

        // Contact Information Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Always show these in compact and full mode
            if (organization != null) ...[
              _buildInfoRow(
                icon: Icons.business,
                text: organization!,
                context: context,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (jobTitle != null) ...[
              _buildInfoRow(
                icon: Icons.person_outline,
                text: jobTitle!,
                context: context,
              ),
              if (!compactCard) const SizedBox(height: AppSpacing.sm),
            ],
            
            // Only show these in full mode (not compact)
            if (!compactCard) ...[
              if (email != null) ...[
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  text: email!,
                  context: context,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (phone != null) ...[
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  text: phone!,
                  context: context,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (location != null)
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  text: location!,
                  context: context,
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: textColor,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(context).copyWith(
              color: textColor.withOpacity(0.95),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}