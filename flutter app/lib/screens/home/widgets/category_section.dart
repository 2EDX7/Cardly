import 'package:flutter/material.dart';
import '../../../widgets/business_card/business_card.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';

class CategorySection extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> cards;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CategorySection({
    super.key,
    required this.category,
    required this.cards,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _iconRotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        GestureDetector(
          onTap: widget.onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                RotationTransition(
                  turns: _iconRotation,
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.lightTextPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category Cards with Animation
        ClipRect(
          child: AnimatedCrossFade(
            firstChild: Column(
              children: widget.cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: BusinessCard(
                  name: card['name'],
                  organization: card['organization'],
                  jobTitle: card['jobTitle'],
                  background: card['background'],
                  compactCard: true,
                  width: double.infinity,
                ),
              )).toList(),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}
