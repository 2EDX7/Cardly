import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isActive = activeIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTabChange(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
          size: 28,
        ),
      ),
    );
  }

  
  final int activeIndex;
  final Function(int) onTabChange;
  const BottomNavBar({
    Key? key,
    this.activeIndex = 1,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, Icons.home_filled, 0),
            _buildNavItem(context, Icons.add, 1),
            _buildNavItem(context, Icons.person, 2),
          ],
        ),
      ),
    );
  }

  
}