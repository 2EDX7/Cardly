import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/spacing.dart';
import 'card_background.dart';
import 'card_front.dart';
import 'card_back.dart';

enum CardSide { front, back }

enum FlipDirection { left, right }

class BusinessCard extends StatefulWidget {
  // Common properties
  final String name;

  // Single background parameter
  final CardBackground? background;

  // Front side properties
  final String? organization;
  final String? jobTitle;
  final String? email;
  final String? phone;
  final String? location;
  final String? logoText;

  // Back side properties
  final String? about;
  final String? website;

  // Styling
  final double width;
  final double? height;
  final double borderRadius;
  final Color textColor;

  // Compact mode
  final bool compactCard;

  // Interaction mode
  final bool enableSwipeFlip; // If true, swipe to flip. If false, tap to flip
  final VoidCallback? onTap; // Custom tap handler (if swipe flip is enabled)

  const BusinessCard({
    super.key,
    required this.name,
    this.background,
    // Front side
    this.organization,
    this.jobTitle,
    this.email,
    this.phone,
    this.location,
    this.logoText,
    // Back side
    this.about,
    this.website,
    // Styling
    this.width = 380,
    this.height,
    this.borderRadius = 24,
    this.textColor = Colors.white,
    // Compact mode
    this.compactCard = false,
    // Interaction
    this.enableSwipeFlip = false,
    this.onTap,
  });

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  FlipDirection _lastFlipDirection = FlipDirection.left;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard({FlipDirection direction = FlipDirection.left}) {
    if (widget.compactCard) return;

    _lastFlipDirection = direction;

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (widget.compactCard || !widget.enableSwipeFlip) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > 500) {
      // Determine flip direction based on swipe direction
      final direction = velocity < 0 ? FlipDirection.left : FlipDirection.right;
      _flipCard(direction: direction);
    }
  }

  double _calculateHeight() {
    if (widget.height != null) return widget.height!;
    return widget.compactCard ? 180 : 280;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactCard) {
      return _buildCard(CardSide.front);
    }

    Widget cardWidget = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate flip angle based on direction
        double angle = _animation.value * math.pi;
        if (_lastFlipDirection == FlipDirection.right) {
          angle = -angle; // Flip in opposite direction
        }

        final isUnder = angle.abs() > math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isUnder
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateY(angle < 0 ? -math.pi : math.pi),
                  child: _buildCard(CardSide.back),
                )
              : _buildCard(CardSide.front),
        );
      },
    );

    if (widget.enableSwipeFlip) {
      return GestureDetector(
        onTap: widget.onTap,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: cardWidget,
      );
    } else {
      return GestureDetector(
        onTap: () => _flipCard(),
        child: cardWidget,
      );
    }
  }

  Widget _buildCard(CardSide side) {
    final bg = widget.background ?? CardBackground.defaultGradient;

    return Container(
      width: widget.width,
      height: _calculateHeight(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // Background layer
            bg.build(),

            // Content layer
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: side == CardSide.front
                  ? CardFront(
                      name: widget.name,
                      logoText: widget.logoText,
                      organization: widget.organization,
                      jobTitle: widget.jobTitle,
                      email: widget.email,
                      phone: widget.phone,
                      location: widget.location,
                      textColor: widget.textColor,
                      compactCard: widget.compactCard,
                    )
                  : CardBack(
                      about: widget.about,
                      website: widget.website,
                      textColor: widget.textColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
