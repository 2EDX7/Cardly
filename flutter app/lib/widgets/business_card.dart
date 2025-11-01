import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

enum CardSide { front, back }

/// Background configuration for business cards
class CardBackground {
  final String? assetPath;
  final Gradient? gradient;
  final Color? color;

  const CardBackground._({
    this.assetPath,
    this.gradient,
    this.color,
  });

  // Asset backgrounds
  static CardBackground asset(String path) => CardBackground._(assetPath: path);
  
  // Predefined asset paths
  static CardBackground get gold => CardBackground._(assetPath: 'assets/images/business_card_backgrounds/Gold.png');
  static CardBackground get green => CardBackground._(assetPath: 'assets/images/business_card_backgrounds/Green.png');
  static CardBackground get grey => CardBackground._(assetPath: 'assets/images/business_card_backgrounds/Grey.png');
  static CardBackground get purple => CardBackground._(assetPath: 'assets/images/business_card_backgrounds/Purple.png');
  static CardBackground get blue => CardBackground._(assetPath: 'assets/images/business_card_backgrounds/blue.png');
  static CardBackground get goldSilver => CardBackground._(assetPath: 'assets/images/business_card_backgrounds/gold_silver.jpg');

  // Gradient backgrounds
  static CardBackground fromGradient(Gradient gradient) => CardBackground._(gradient: gradient);
  
  static CardBackground get defaultGradient => CardBackground._(
    gradient: const LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static CardBackground get purpleBlue => CardBackground._(
    gradient: const LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static CardBackground get orangePink => CardBackground._(
    gradient: const LinearGradient(
      colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static CardBackground get greenBlue => CardBackground._(
    gradient: const LinearGradient(
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static CardBackground get sunset => CardBackground._(
    gradient: const LinearGradient(
      colors: [Color(0xFFfa709a), Color(0xFFfee140)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Solid color backgrounds
  static CardBackground fromColor(Color color) => CardBackground._(color: color);
  
  static CardBackground get primarySolid => CardBackground._(color: const Color(0xFF7C3AED));
  static CardBackground get secondarySolid => CardBackground._(color: const Color(0xFF06B6D4));
  static CardBackground get darkSolid => CardBackground._(color: const Color(0xFF1F2937));
  static CardBackground get blueSolid => CardBackground._(color: const Color(0xFF3B82F6));
}

class BusinessCard extends StatefulWidget {
  // Common properties
  final String name;
  
  // Single background parameter - accepts asset, gradient, or color
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
  final double height;
  final double borderRadius;
  final Color textColor;

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
    // Styling - Fixed dimensions
    this.width = 340,
    this.height = 260,
    this.borderRadius = 24,
    this.textColor = Colors.white,
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
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  Future<void> _launchWebsite() async {
    if (widget.website == null) return;

    // Add https:// if not present
    String url = widget.website!;
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
    return Container(
      width: widget.width,
      height: widget.height,
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
            _buildBackground(),
            // Content layer
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: side == CardSide.front
                  ? _buildFrontSide(context)
                  : _buildBackSide(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final bg = widget.background;

    if (bg == null) {
      // Default gradient if nothing specified
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: CardBackground.defaultGradient.gradient,
          ),
        ),
      );
    }

    // Priority: Asset > Gradient > Color
    if (bg.assetPath != null) {
      return Positioned.fill(
        child: Image.asset(
          bg.assetPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint(' Failed to load asset: ${bg.assetPath}');
            // Fallback to gradient or color
            if (bg.gradient != null) {
              return Container(decoration: BoxDecoration(gradient: bg.gradient));
            } else if (bg.color != null) {
              return Container(color: bg.color);
            } else {
              return Container(
                decoration: BoxDecoration(gradient: CardBackground.defaultGradient.gradient),
              );
            }
          },
        ),
      );
    } else if (bg.gradient != null) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(gradient: bg.gradient),
        ),
      );
    } else if (bg.color != null) {
      return Positioned.fill(
        child: Container(color: bg.color),
      );
    }

    // Fallback
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(gradient: CardBackground.defaultGradient.gradient),
      ),
    );
  }

  Widget _buildFrontSide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header with Name and Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.name,
                style: AppTextStyles.heading1(context).copyWith(
                  color: widget.textColor,
                  fontSize: 26,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.logoText != null) ...[
              const SizedBox(width: AppSpacing.md),
              Text(
                widget.logoText!,
                style: AppTextStyles.heading2(context).copyWith(
                  color: widget.textColor.withOpacity(0.9),
                  fontSize: 28,
                ),
              ),
            ],
          ],
        ),

        // Contact Information Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.organization != null) ...[
              _buildInfoRow(
                icon: Icons.business,
                text: widget.organization!,
                context: context,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (widget.jobTitle != null) ...[
              _buildInfoRow(
                icon: Icons.person_outline,
                text: widget.jobTitle!,
                context: context,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (widget.email != null) ...[
              _buildInfoRow(
                icon: Icons.email_outlined,
                text: widget.email!,
                context: context,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (widget.phone != null) ...[
              _buildInfoRow(
                icon: Icons.phone_outlined,
                text: widget.phone!,
                context: context,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (widget.location != null)
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                text: widget.location!,
                context: context,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackSide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Section
        Text(
          'About',
          style: AppTextStyles.heading3(context).copyWith(
            color: widget.textColor.withOpacity(0.9),
            fontSize: 16,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // About Description
        if (widget.about != null)
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.about!,
                style: AppTextStyles.body(context).copyWith(
                  color: widget.textColor.withOpacity(0.85),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.md),

        // Website at the bottom center - CLICKABLE
        if (widget.website != null)
          Center(
            child: GestureDetector(
              onTap: () {
                _launchWebsite();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: widget.textColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: widget.textColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: widget.textColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      widget.website!,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: widget.textColor,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.open_in_new,
                      color: widget.textColor,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: widget.textColor,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(context).copyWith(
              color: widget.textColor.withOpacity(0.95),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}