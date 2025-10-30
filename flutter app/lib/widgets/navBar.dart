import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  Widget _buildNavItem(IconData icon, int index) {
    final isActive = activeIndex == index;
    return GestureDetector(
      onTap: () => onTabChange(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5B5FEF) : const Color(0xF6F7F8FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF5B5FEF),
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.add, 1),
            _buildNavItem(Icons.person, 2),
          ],
        ),
      ),
    );
  }

  
}