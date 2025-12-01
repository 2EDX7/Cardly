import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:cardly/presentation/widgets/business_card/card_background.dart";
import "package:cardly/presentation/theme/colors.dart";
import "package:cardly/presentation/theme/spacing.dart";
import "package:cardly/presentation/theme/typography.dart";
import "package:cardly/presentation/screens/profile/widgets/card_preview_section.dart";
import "package:cardly/presentation/screens/profile/widgets/color_picker_widget.dart";
import "package:cardly/presentation/screens/profile/widgets/background_picker_widget.dart";
import "package:cardly/presentation/screens/profile/widgets/profile_action_buttons.dart";
import "package:cardly/presentation/screens/profile/widgets/custom_color_picker_dialog.dart";
import "package:cardly/presentation/screens/profile/edit_card_page.dart";
import "package:cardly/data/models/card_info.dart";
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';
import '../../../logic/cubits/theme/theme_cubit.dart';
import '../../../logic/cubits/theme/theme_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {

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
    
    // Initialize with empty card info (will be loaded from cubit)
    _cardInfo = CardInfo.empty();
    
    // Load user's card from cubit
    _loadUserCard();
  }
  
  void _loadUserCard() {
    final cardState = context.read<CardCubit>().state;
    if (cardState is CardLoaded && cardState.cards.isNotEmpty) {
      // Load the first card as the user's profile card
      // In a real app, you'd have a specific "my card" or filter by user ID
      setState(() {
        _cardInfo = cardState.cards.first;
        _selectedBackground = _cardInfo.background ?? CardBackground.defaultGradient;
      });
    } else {
      // Initialize with default data if no cards exist
      _cardInfo = CardInfo(
        name: 'Your Name',
        organization: 'Your Company',
        jobTitle: 'Your Title',
        email: 'your.email@example.com',
        phone: '0000000000',
        location: 'Your Location',
        about: 'Tell us about yourself',
        website: 'www.example.com',
      );
    }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          'Preview Card',
          style: AppTextStyles.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
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

            const SizedBox(height: AppSpacing.xl),

            // Theme Settings Section
            _buildThemeSection(context),

            const SizedBox(height: AppSpacing.xxl),

            // Action Buttons
            BlocConsumer<CardCubit, CardState>(
              listener: (context, state) {
                if (state is CardUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Card saved successfully!'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                } else if (state is CardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is CardLoading;
                
                return ProfileActionButtons(
                  onEditPressed: () async {
                    final CardInfo? updatedCardInfo = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditCardPage(cardInfo: _cardInfo),
                      ),
                    );
                    
                    if (updatedCardInfo != null) {
                      // Update the card in the cubit
                      await context.read<CardCubit>().updateCard(updatedCardInfo);
                      
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
                  onSavePressed: isLoading ? null : () {
                    // Save customizations (background and text color)
                    final updatedCard = _cardInfo.copyWith(
                      background: _selectedBackground,
                    );
                    
                    context.read<CardCubit>().updateCard(updatedCard);
                    
                    setState(() {
                      _cardInfo = updatedCard;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Theme',
          style: AppTextStyles.heading3(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isDarkMode = themeState.themeMode == ThemeMode.dark;
            final isSystemMode = themeState.themeMode == ThemeMode.system;
            
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Light/Dark Toggle
                  ListTile(
                    leading: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: AppTextStyles.body(context),
                    ),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: isSystemMode ? null : (value) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                    onTap: () {
                      if (!isSystemMode) {
                        context.read<ThemeCubit>().toggleTheme();
                      }
                    },
                  ),
                  
                  Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
                  
                  // System Mode Toggle
                  ListTile(
                    leading: Icon(
                      Icons.settings_brightness,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Use System Theme',
                      style: AppTextStyles.body(context),
                    ),
                    trailing: Switch(
                      value: isSystemMode,
                      onChanged: (value) {
                        if (value) {
                          context.read<ThemeCubit>().setSystemTheme();
                        } else {
                          context.read<ThemeCubit>().setLightTheme();
                        }
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                    onTap: () {
                      if (isSystemMode) {
                        context.read<ThemeCubit>().setLightTheme();
                      } else {
                        context.read<ThemeCubit>().setSystemTheme();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}