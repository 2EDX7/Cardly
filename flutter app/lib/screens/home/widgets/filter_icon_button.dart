import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterIconButton extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final VoidCallback? onTap;
  final double size;

  const FilterIconButton({
    super.key,
    this.icon,
    this.svgPath,
    this.onTap,
    this.size = 20,
  }) : assert(icon != null || svgPath != null, 'Either icon or svgPath must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: svgPath != null
            ? SvgPicture.asset(
                svgPath!,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF5B5FEF),
                  BlendMode.srcIn,
                ),
              )
            : Icon(
                icon,
                color: const Color(0xFF5B5FEF),
                size: 24,
              ),
      ),
    );
  }
}
