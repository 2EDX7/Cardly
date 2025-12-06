import 'package:flutter/material.dart';

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
  static CardBackground get gold => CardBackground._(
        assetPath: 'assets/images/business_card_backgrounds/Gold.png',
      );

  static CardBackground get green => CardBackground._(
        assetPath: 'assets/images/business_card_backgrounds/Green.png',
      );

  static CardBackground get grey => CardBackground._(
        assetPath: 'assets/images/business_card_backgrounds/Grey.png',
      );

  static CardBackground get purple => CardBackground._(
        assetPath: 'assets/images/business_card_backgrounds/Purple.png',
      );

  static CardBackground get blue => CardBackground._(
        assetPath: 'assets/images/business_card_backgrounds/Rectangle.png',
      );

  static CardBackground get goldSilver => CardBackground._(
        assetPath: 'assets/images/business_card_backgrounds/gold_silver.jpg',
      );

  // Gradient backgrounds
  static CardBackground fromGradient(Gradient gradient) =>
      CardBackground._(gradient: gradient);

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
  static CardBackground fromColor(Color color) =>
      CardBackground._(color: color);

  static CardBackground get primarySolid =>
      CardBackground._(color: const Color(0xFF7C3AED));

  static CardBackground get secondarySolid =>
      CardBackground._(color: const Color(0xFF06B6D4));

  static CardBackground get darkSolid =>
      CardBackground._(color: const Color(0xFF1F2937));

  static CardBackground get blueSolid =>
      CardBackground._(color: const Color(0xFF3B82F6));

  /// Get a readable name for this background
  String getBackgroundName() {
    if (assetPath != null) {
      if (assetPath!.contains('Gold.png')) return 'gold';
      if (assetPath!.contains('Green.png')) return 'green';
      if (assetPath!.contains('Grey.png')) return 'grey';
      if (assetPath!.contains('Purple.png')) return 'purple';
      if (assetPath!.contains('Rectangle.png')) return 'blue';
      if (assetPath!.contains('gold_silver.jpg')) return 'goldSilver';
    }
    
    if (gradient != null) {
      final colors = gradient is LinearGradient 
          ? (gradient as LinearGradient).colors 
          : <Color>[];
      if (_sameColors(colors, defaultGradient.gradient!.colors)) return 'defaultGradient';
      if (_sameColors(colors, purpleBlue.gradient!.colors)) return 'purpleBlue';
      if (_sameColors(colors, orangePink.gradient!.colors)) return 'orangePink';
      if (_sameColors(colors, greenBlue.gradient!.colors)) return 'greenBlue';
      if (_sameColors(colors, sunset.gradient!.colors)) return 'sunset';
    }
    
    if (color != null) {
      if (color!.value == primarySolid.color!.value) return 'primarySolid';
      if (color!.value == secondarySolid.color!.value) return 'secondarySolid';
      if (color!.value == darkSolid.color!.value) return 'darkSolid';
      if (color!.value == blueSolid.color!.value) return 'blueSolid';
    }
    
    return 'unknown';
  }

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value) return false;
    }
    return true;
  }

  @override
  String toString() => 'CardBackground(${getBackgroundName()})';

  /// Build the background widget

  Widget build() {
    // Priority: Asset > Gradient > Color
    if (assetPath != null) {
      return Positioned.fill(
        child: Image.asset(
          assetPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Failed to load asset: $assetPath');
            // Fallback to gradient or color
            if (gradient != null) {
              return Container(decoration: BoxDecoration(gradient: gradient));
            } else if (color != null) {
              return Container(color: color);
            } else {
              return Container(
                decoration: BoxDecoration(gradient: defaultGradient.gradient),
              );
            }
          },
        ),
      );
    } else if (gradient != null) {
      return Positioned.fill(
        child: Container(decoration: BoxDecoration(gradient: gradient)),
      );
    } else if (color != null) {
      return Positioned.fill(
        child: Container(color: color),
      );
    }

    // Fallback
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(gradient: defaultGradient.gradient),
      ),
    );
  }
}
