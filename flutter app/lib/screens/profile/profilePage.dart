import 'package:flutter/material.dart';
import "package:cardly/widgets/navBar.dart";
import "package:cardly/widgets/business_card/card_background.dart";
import "package:cardly/theme/colors.dart";
import "package:cardly/theme/spacing.dart";
import "package:cardly/theme/typography.dart";
import "package:cardly/screens/profile/widgets/card_preview_section.dart";
import "package:cardly/screens/profile/widgets/color_picker_widget.dart";
import "package:cardly/screens/profile/widgets/background_picker_widget.dart";
import "package:cardly/screens/profile/widgets/profile_action_buttons.dart";
import "package:cardly/screens/profile/widgets/custom_color_picker_dialog.dart";
import "package:cardly/screens/profile/edit_card_page.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _activeNavIndex = 2;

  // Card customization state
  Color _selectedFontColor = Colors.white;
  CardBackground _selectedBackground = CardBackground.defaultGradient;
  bool _isFlipped = false;

  // Card information state
  late CardInfo _cardInfo;

  // Animation controller for card flip
  late AnimationController _flipController;

  // Font color options
  final List<Color> _fontColors = [
    Colors.white,
    Colors.black,
    const Color(0xFFFF0000), // Red
    const Color(0xFF8B00FF), // Purple
    const Color(0xFF00FF00), // Green
    // const Color(0xFF00B8FF), // Blue
  ];

  // Background options using predefined CardBackground
  final List<CardBackground> _backgrounds = [
    CardBackground.defaultGradient,
    CardBackground.gold,
    CardBackground.green,
    CardBackground.grey,
    CardBackground.purple,
    // CardBackground.blue,

  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Initialize card info
    _cardInfo = CardInfo(
      name: 'Imed Bouchrika',
      // logoText: 'ensia',
      organization: 'ENSIA',
      jobTitle: 'Assistant Professor',
      email: 'imed.bouchrika@ensia.edu.dz',
      phone: '0557317584',
      location: 'Sidi Abdellah - Algiers',
      about:
          'Professor Bouchrika has been actively involved in launching a number of start-up companies in the IT and academic sectors. Motivated by feedback and recommendations from leading scientists around the world.',
      website: 'www.google.com',
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Preview Card',
          style: AppTextStyles.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Preview Section
            CardPreviewSection(
              name: _cardInfo.name,
              // logoText: _cardInfo.logoText,
              organization: _cardInfo.organization,
              jobTitle: _cardInfo.jobTitle,
              email: _cardInfo.email,
              phone: _cardInfo.phone,
              location: _cardInfo.location,
              about: _cardInfo.about,
              website: _cardInfo.website,
              background: _selectedBackground,
              textColor: _selectedFontColor,
              onCardTap: _flipCard,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Color Picker Section
            ColorPickerWidget(
              selectedColor: _selectedFontColor,
              colors: _fontColors,
              onColorSelected: (color) {
                setState(() {
                  _selectedFontColor = color;
                });
              },
              onCustomColorPressed: () async {
                final Color? color = await showCustomColorPicker(
                  context,
                  initialColor: _selectedFontColor,
                );
                if (color != null) {
                  setState(() {
                    _selectedFontColor = color;
                  });
                }
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Background Picker Section
            BackgroundPickerWidget(
              selectedBackground: _selectedBackground,
              backgrounds: _backgrounds,
              onBackgroundSelected: (background) {
                setState(() {
                  _selectedBackground = background;
                });
              },
              onCustomBackgroundPressed: () {
                // TODO: Implement custom background picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Custom background picker - To be implemented'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Action Buttons
            ProfileActionButtons(
              onEditPressed: () async {
                final CardInfo? updatedCardInfo = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditCardPage(cardInfo: _cardInfo),
                  ),
                );
                
                if (updatedCardInfo != null) {
                  setState(() {
                    _cardInfo = updatedCardInfo;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Card information updated!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              onSavePressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Card saved successfully!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _activeNavIndex,
        onTabChange: (index) {
          setState(() {
            _activeNavIndex = index;
          });
        },
      ),
    );
  }
}