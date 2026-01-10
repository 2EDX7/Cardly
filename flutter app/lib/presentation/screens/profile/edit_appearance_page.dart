import 'package:flutter/material.dart';
import 'package:cardly/presentation/widgets/business_card/business_card.dart';
import 'package:cardly/presentation/widgets/business_card/card_background.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/data/models/card_info.dart';
import '../../../l10n/app_localizations.dart';

class EditAppearancePage extends StatefulWidget {
  final CardInfo card;

  const EditAppearancePage({super.key, required this.card});

  @override
  State<EditAppearancePage> createState() => _EditAppearancePageState();
}

class _EditAppearancePageState extends State<EditAppearancePage> {
  late CardBackground _selectedBackground;
  late Color _selectedFontColor;
  bool _isFlipped = false;

  // Background options - 10 unique backgrounds
  final List<CardBackground> _backgrounds = [
    CardBackground.defaultGradient,
    CardBackground.gold,
    CardBackground.green,
    CardBackground.grey,
    CardBackground.purple,
    CardBackground.purpleBlue,
    CardBackground.orangePink,
    CardBackground.greenBlue,
    CardBackground.sunset,
    CardBackground.blackSolid,
  ];

  // Font color options - 19 colors + 1 custom slot (4 rows of 5)
  final List<Color> _fontColors = [
    Colors.white,
    Colors.black,
    const Color(0xFFFF0000), // Red
    const Color(0xFF8B00FF), // Purple
    const Color(0xFF00FF00), // Green
    const Color(0xFF00B8FF), // Blue
    const Color(0xFFFFD700), // Gold
    const Color(0xFFFF69B4), // Pink
    const Color(0xFFFF8C00), // Orange
    const Color(0xFF00CED1), // Turquoise
    const Color(0xFFDC143C), // Crimson
    const Color(0xFF4B0082), // Indigo
    const Color(0xFF32CD32), // Lime
    const Color(0xFFFF1493), // Deep Pink
    const Color(0xFF1E90FF), // Dodger Blue
    const Color(0xFF8B4513), // Saddle Brown
    const Color(0xFF2F4F4F), // Dark Slate Gray
    const Color(0xFFFF4500), // Orange Red
    const Color(0xFF9370DB), // Medium Purple
  ];

  @override
  void initState() {
    super.initState();
    _selectedBackground =
        widget.card.background ?? CardBackground.defaultGradient;
    _selectedFontColor = widget.card.fontColor ?? Colors.white;
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Edit Appearance',
          style: AppTextStyles.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Return the updated card with new appearance
              final updatedCard = widget.card.copyWith(
                background: _selectedBackground,
                fontColor: _selectedFontColor,
              );
              Navigator.of(context).pop(updatedCard);
            },
            child: Text(
              l10n.save,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Preview
            Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: BusinessCard(
                  name: widget.card.name,
                  organization: widget.card.organization,
                  jobTitle: widget.card.jobTitle,
                  email: widget.card.email,
                  phone: widget.card.phone,
                  location: widget.card.location,
                  about: widget.card.about,
                  website: widget.card.website,
                  background: _selectedBackground,
                  textColor: _selectedFontColor,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Center(
              child: Text(
                l10n.tapToFlip,
                style: AppTextStyles.caption(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Background Section
            Text(
              l10n.changeBackground,
              style: AppTextStyles.heading3(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBackgroundGrid(),

            const SizedBox(height: AppSpacing.xl),

            // Font Color Section
            Text(
              l10n.changeFontColor,
              style: AppTextStyles.heading3(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFontColorGrid(),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _backgrounds.length,
      itemBuilder: (context, index) {
        final background = _backgrounds[index];
        final isSelected = background == _selectedBackground;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBackground = background;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: background.build(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _fontColors.length + 1, // +1 for custom color
      itemBuilder: (context, index) {
        // Last item is custom color picker
        if (index == _fontColors.length) {
          return GestureDetector(
            onTap: () => _showCustomColorDialog(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        }

        final color = _fontColors[index];
        final isSelected = color == _selectedFontColor;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFontColor = color;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : color == Colors.white
                        ? AppColors.divider
                        : Colors.transparent,
                width: isSelected ? 3 : (color == Colors.white ? 1 : 0),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCustomColorDialog() {
    String colorInput = '';
    String selectedFormat = 'Hex'; // Default to Hex

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Custom Color',
                style: AppTextStyles.heading3(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select format:',
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedFormat = 'Hex';
                                  colorInput = '';
                                });
                              },
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedFormat == 'Hex'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(11),
                                  ),
                                ),
                                child: Text(
                                  'Hex Code',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedFormat == 'Hex'
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedFormat = 'RGB';
                                  colorInput = '';
                                });
                              },
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedFormat == 'RGB'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(11),
                                  ),
                                ),
                                child: Text(
                                  'RGB',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedFormat == 'RGB'
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText:
                            selectedFormat == 'Hex' ? 'Hex Code' : 'RGB Values',
                        hintText:
                            selectedFormat == 'Hex' ? '#FF5733' : '255,87,51',
                        helperText: selectedFormat == 'Hex'
                            ? 'Format: #RRGGBB or RRGGBB'
                            : 'Format: R,G,B (0-255)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          selectedFormat == 'Hex' ? Icons.tag : Icons.palette,
                        ),
                      ),
                      onChanged: (value) {
                        colorInput = value;
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Color? newColor;

                    if (selectedFormat == 'Hex') {
                      newColor = _parseHexColor(colorInput);
                    } else {
                      newColor = _parseRgbColor(colorInput);
                    }

                    if (newColor != null) {
                      setState(() {
                        _selectedFontColor = newColor!;
                      });
                      Navigator.of(dialogContext).pop();
                    } else {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            selectedFormat == 'Hex'
                                ? 'Invalid hex code. Use format: #RRGGBB or RRGGBB'
                                : 'Invalid RGB values. Use format: R,G,B (0-255)',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color? _parseHexColor(String hexString) {
    try {
      // Remove # if present and any whitespace
      hexString =
          hexString.replaceAll('#', '').replaceAll(' ', '').toUpperCase();

      // Check if valid length (6 or 8 characters)
      if (hexString.length != 6 && hexString.length != 8) {
        return null;
      }

      // Check if all characters are valid hex digits
      if (!RegExp(r'^[0-9A-F]+$').hasMatch(hexString)) {
        return null;
      }

      // Add alpha channel if not present
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }

      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      return null;
    }
  }

  Color? _parseRgbColor(String rgbString) {
    try {
      // Remove any spaces and split by comma
      final parts = rgbString.replaceAll(' ', '').split(',');

      if (parts.length != 3) {
        return null;
      }

      final r = int.parse(parts[0]);
      final g = int.parse(parts[1]);
      final b = int.parse(parts[2]);

      // Validate range 0-255
      if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
        return null;
      }

      return Color.fromARGB(255, r, g, b);
    } catch (e) {
      return null;
    }
  }
}
