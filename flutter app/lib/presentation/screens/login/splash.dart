import 'package:cardly/presentation/widgets/business_card/card_background.dart';
import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/business_card/business_card.dart';
import '../../../routes/routes.dart';
import 'package:cardly/src/generated/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/auth/auth_state.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/profile_card/profile_card_cubit.dart';
import '../../../logic/cubits/theme/theme_cubit.dart';
import '../../../logic/cubits/language/language_cubit.dart';

class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      final user = authState.user!;
      
      // Set user context
      context.read<CardCubit>().setUser(user.id);
      
      // Load card data from user object (already fetched from DB with LEFT JOIN)
      context.read<ProfileCardCubit>().loadCardFromUser(user);
      
      // Load user preferences for theme and language
      final themeMode = ThemeCubit.themeModeFromString(user.themeMode);
      final locale = LanguageCubit.localeFromString(user.language);
      
      await context.read<ThemeCubit>().setUser(user.id, initialTheme: themeMode);
      await context.read<LanguageCubit>().setUser(user.id, initialLocale: locale);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // TOP SECTION - Primary Color Background with STATIC Business Card
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: cs.primary,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: BusinessCard(
                    name: 'Imed Bouchrika',
                    logoText: 'ensia',
                    organization: 'ENSIA',
                    jobTitle: 'Assistant Professor',
                    email: 'imed.bouchrika@ensia.edu.dz',
                    phone: '0557317584',
                    location: 'Sidi Abdellah - Algiers',
                    about: 'Professor Bouchrika has been actively involved in launching a number of start-up companies in the IT and academic sectors. Motivated by feedback and recommendations from leading scientists around the world.',
                    website: 'www.google.com',
                    background: CardBackground.purple,
                  ),
                ),
              ),
            ),
          ),

          // BOTTOM SECTION - White Background with SWIPEABLE Content
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? cs.primary
                                : cs.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Swipeable Content Area
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          // Page 1: Digital Business Cards
                          _buildFeatureContent(
                            context,
                            icon: Icons.credit_card,
                            title: AppLocalizations.of(context)!.splashTitle,
                            subtitle: AppLocalizations.of(context)!.splashSubtitle,
                            description:
                                AppLocalizations.of(context)!.splashDescription,
                          ),

                          // Page 2: Instant Sharing
                          _buildFeatureContent(
                            context,
                            icon: Icons.qr_code_2,
                            title: AppLocalizations.of(context)!.shareInstantly,
                            subtitle: AppLocalizations.of(context)!.connectWithTap,
                            description:
                                AppLocalizations.of(context)!.shareInstantlyDescription,
                          ),

                          // Page 3: Eco-Friendly
                          _buildFeatureContent(
                            context,
                            icon: Icons.eco,
                            title: AppLocalizations.of(context)!.ecoFriendly,
                            subtitle: AppLocalizations.of(context)!.goGreenGoDigital,
                            description:
                                AppLocalizations.of(context)!.ecoFriendlyDescription,
                          ),
                        ],
                      ),
                    ),

                    // Log In Button - Fixed at bottom
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.login);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.logIn,
                            style: AppTextStyles.buttonPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureContent(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: cs.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            title,
            style: AppTextStyles.heading1(context).copyWith(
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.heading3(context).copyWith(
              color: cs.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // // Description
          // Text(
          //   description,
          //   style: AppTextStyles.body(context).copyWith(
          //     color: cs.onSurface.withOpacity(0.6),
          //     height: 1.6,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ],
        ),
      ),
    );
  }
}