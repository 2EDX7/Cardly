import 'package:flutter/material.dart';
import '../../../widgets/business_card/business_card.dart';
import '../../../widgets/business_card/card_background.dart';
import '../../../theme/spacing.dart';
import '../../../../data/models/card_info.dart';

class CardListItem extends StatelessWidget {
  final CardInfo card;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const CardListItem({
    super.key,
    required this.card,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GestureDetector(
        onTap: onTap,
        child: BusinessCard(
          name: card.name,
          organization: card.organization,
          jobTitle: card.jobTitle,
          background: card.background ?? CardBackground.defaultGradient,
          compactCard: true,
          width: double.infinity,
        ),
      ),
    );
  }
}
