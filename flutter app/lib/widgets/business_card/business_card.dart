import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/spacing.dart';
import 'card_background.dart';
import 'card_front.dart';
import 'card_back.dart';

enum CardSide { front, back }

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
    this.width = 340,
    this.height,
    this.borderRadius = 24,
    this.textColor = Colors.white,
    // Compact mode
    this.compactCard = false,
  });

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

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

  void _flipCard() {
    if (widget.compactCard) return;

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  double _calculateHeight() {
    if (widget.height != null) return widget.height!;
    return widget.compactCard ? 180 : 260;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactCard) {
      return _buildCard(CardSide.front);
    }

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isUnder = angle > math.pi / 2;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isUnder
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCard(CardSide.back),
                  )
                : _buildCard(CardSide.front),
          );
        },
      ),
    );
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