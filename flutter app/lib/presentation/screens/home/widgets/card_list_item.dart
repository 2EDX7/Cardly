import 'package:flutter/material.dart';
import '../../../widgets/business_card/business_card.dart';
import '../../../theme/spacing.dart';

class CardListItem extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback? onDelete;

  const CardListItem({
    super.key,
    required this.card,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: BusinessCard(
        name: card['name'],
        organization: card['organization'],
        jobTitle: card['jobTitle'],
        background: card['background'],
        compactCard: true,
        width: double.infinity,
      ),
    );
  }
}
