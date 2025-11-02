import 'package:flutter/material.dart';
import 'package:cardly/theme/typography.dart';

/// Reusable section label widget for profile page sections
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.overline(context).copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
