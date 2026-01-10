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
import '../../../logic/cubits/profile_card/profile_card_cubit.dart';
import '../../../logic/cubits/profile_card/profile_card_state.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/theme/theme_cubit.dart';
import '../../../logic/cubits/theme/theme_state.dart';
import '../../../logic/cubits/language/language_cubit.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import './widgets/LanguageSection_widget.dart';
// import 'package:cardly/src/generated/l10n/app_localizations.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../qr/show_qr_code_screen.dart';

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

  // Track if user has manually changed selections
  bool _userChangedBackground = false;
  bool _userChangedFontColor = false;

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
  ];

  // Background options using predefined CardBackground
  final List<CardBackground> _backgrounds = [
    CardBackground.defaultGradient,
    CardBackground.gold,
    CardBackground.green,
    CardBackground.grey,
    CardBackground.purple,
    CardBackground.blue,
    CardBackground.goldSilver,
    CardBackground.purpleBlue,
    CardBackground.orangePink,
    CardBackground.greenBlue,
    CardBackground.sunset,
    CardBackground.primarySolid,
    CardBackground.secondarySolid,
    CardBackground.darkSolid,
    CardBackground.blueSolid,
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start with a sensible default; will be replaced once the cubit loads data.
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          l10n.previewCard,
          style: AppTextStyles.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Logging out...',
                            style: AppTextStyles.body(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Reset cubits to initial state on logout
              context.read<ProfileCardCubit>().reset();
              context.read<CardCubit>().reset();
              context.read<ThemeCubit>().resetToDefault();
              context.read<LanguageCubit>().resetToDefault();
              context.read<AuthCubit>().logout();

              // Small delay for smooth UX
              await Future.delayed(const Duration(milliseconds: 500));

              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            icon: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.onBackground),
          ),
        ],
      ),
      body: BlocConsumer<ProfileCardCubit, ProfileCardState>(
        listener: (context, state) {
          debugPrint('👀 ProfilePage listener state: ${state.runtimeType}');
          if (state is ProfileCardLoaded) {
            final bgName = state.card.background?.getBackgroundName() ?? 'null';
            final colorHex = state.card.fontColor != null
                ? '#${(state.card.fontColor?.value ?? 0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}'
                : 'null';
            debugPrint(
                '👀 ProfilePage received card: name=${state.card.name}, bg=$bgName, fontColor=$colorHex');
            // Update the internal state so edits work correctly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _cardInfo = state.card;
                // Only sync if user hasn't manually changed these
                if (!_userChangedBackground) {
                  _selectedBackground =
                      state.card.background ?? CardBackground.defaultGradient;
                }
                if (!_userChangedFontColor) {
                  _selectedFontColor = state.card.fontColor ?? Colors.white;
                }
              });
            });
          } else if (state is ProfileCardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint('👀 ProfilePage builder state: ${state.runtimeType}');

          // Determine if we have a card or not
          final hasCard = state is ProfileCardLoaded;
          final isLoading = state is ProfileCardLoading;
          final isError = state is ProfileCardError;

          // Get card data if available, otherwise use default
          final card = hasCard ? (state as ProfileCardLoaded).card : _cardInfo;
          final displayBackground = _userChangedBackground
              ? _selectedBackground
              : (hasCard
                  ? ((state as ProfileCardLoaded).card.background ??
                      _selectedBackground)
                  : _selectedBackground);
          final displayFontColor = _userChangedFontColor
              ? _selectedFontColor
              : (hasCard
                  ? ((state as ProfileCardLoaded).card.fontColor ??
                      _selectedFontColor)
                  : _selectedFontColor);

          return SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Preview Section - Show loading, error, empty state, or card
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (isError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            (state as ProfileCardError).message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProfileCardCubit>()
                                .loadProfileCard(),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (!hasCard)
                  _buildEmptyCardSection(context, l10n)
                else
                  CardPreviewSection(
                    name: card.name,
                    organization: card.organization,
                    jobTitle: card.jobTitle,
                    email: card.email,
                    phone: card.phone,
                    location: card.location,
                    about: card.about,
                    website: card.website,
                    background: displayBackground,
                    textColor: displayFontColor,
                    onCardTap: _flipCard,
                    shareableId: card.shareableId,
                  ),

                // Action buttons under card (Edit and Share)
                if (hasCard)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProfileActionButton(
                          icon: Icons.edit,
                          label: l10n.edit,
                          onTap: () async {
                            final CardInfo? updatedCardInfo =
                                await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditCardPage(cardInfo: card),
                              ),
                            );

                            if (updatedCardInfo != null) {
                              debugPrint(
                                  ' Saving card: name=${updatedCardInfo.name}, bg=${updatedCardInfo.background}, fontColor=${updatedCardInfo.fontColor}');
                              await context
                                  .read<ProfileCardCubit>()
                                  .saveProfileCard(updatedCardInfo);

                              setState(() {
                                _cardInfo = updatedCardInfo;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.cardInformationUpdated),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        _ProfileActionButton(
                          icon: Icons.share,
                          label: l10n.share,
                          onTap: () {
                            if (card.shareableId != null &&
                                card.shareableId!.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ShowQrCodeScreen(card: card),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Card not saved or ID missing. Please save first."),
                                ),
                              );
                            }
                          },
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.xl),

                // Only show color and background pickers if user has a card
                if (hasCard) ...[
                  ColorPickerWidget(
                    selectedColor: displayFontColor,
                    colors: _fontColors,
                    onColorSelected: (color) {
                      setState(() {
                        _selectedFontColor = color;
                        _userChangedFontColor = true;
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
                          _userChangedFontColor = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BackgroundPickerWidget(
                    selectedBackground: displayBackground,
                    backgrounds: _backgrounds,
                    onBackgroundSelected: (bg) {
                      setState(() {
                        _selectedBackground = bg;
                        _userChangedBackground = true;
                      });
                    },
                    onCustomBackgroundPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .customBackgroundPicker),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                _buildThemeSection(context),

                const SizedBox(height: AppSpacing.xl),

                const LanguagesectionWidget(),

                const SizedBox(height: AppSpacing.xxl),

                // Save Settings Button (saves theme and language only)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Just show confirmation that settings are saved
                      // Theme and language are already auto-saved by their respective cubits
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Settings saved successfully'),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                    child: Text(
                      'Save Settings',
                      style: AppTextStyles.buttonPrimary(context).copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCardSection(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outline.withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_outlined,
                size: 64, color: cs.primary.withOpacity(0.7)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noCardsAvailable,
              style: AppTextStyles.heading3(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.addYourFirstCard,
              style: AppTextStyles.body(context)
                  .copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => EditCardPage(cardInfo: CardInfo.empty()),
                  ),
                )
                    .then((value) {
                  if (value is CardInfo) {
                    context.read<ProfileCardCubit>().saveProfileCard(value);
                    setState(() {
                      _cardInfo = value;
                    });
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addCard),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appTheme,
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
                      isDarkMode ? l10n.darkMode : l10n.lightMode,
                      style: AppTextStyles.body(context),
                    ),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: isSystemMode
                          ? null
                          : (value) {
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

                  Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withOpacity(0.2)),

                  // System Mode Toggle
                  ListTile(
                    leading: Icon(
                      Icons.settings_brightness,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      l10n.useSystemTheme,
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

/// Action button widget for edit/share in profile
class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
