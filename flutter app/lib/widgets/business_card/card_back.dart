import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

class CardBack extends StatelessWidget {
  final String? about;
  final String? website;
  final Color textColor;

  const CardBack({
    super.key,
    this.about,
    this.website,
    this.textColor = Colors.white,
  });

  Future<void> _launchWebsite(BuildContext context) async {
    if (website == null) return;

    // Add https:// if not present
    String url = website!;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening website: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Section
        Text(
          'About',
          style: AppTextStyles.heading3(context).copyWith(
            color: textColor.withOpacity(0.9),
            fontSize: 16,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // About Description
        if (about != null)
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                about!,
                style: AppTextStyles.body(context).copyWith(
                  color: textColor.withOpacity(0.85),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.md),

        // Website at the bottom center - CLICKABLE
        if (website != null)
          Center(
            child: GestureDetector(
              onTap: () => _launchWebsite(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: textColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: textColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      website!,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.open_in_new,
                      color: textColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}