import 'package:cardly/widgets/business_card/card_background.dart';
import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/business_card/business_card.dart';
import 'login.dart';

class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
                    compactCard: true,
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
                            title: 'Cardly',
                            subtitle: 'Your Digital Business Cards,\nReimagined',
                            description:
                                'Create stunning digital business cards that make lasting impressions. Share your contact information instantly with anyone, anywhere.',
                          ),

                          // Page 2: Instant Sharing
                          _buildFeatureContent(
                            context,
                            icon: Icons.qr_code_2,
                            title: 'Share Instantly',
                            subtitle: 'Connect with a Tap',
                            description:
                                'Share your contact info with a simple QR code scan or tap. No more fumbling with paper cards or typing details manually.',
                          ),

                          // Page 3: Eco-Friendly
                          _buildFeatureContent(
                            context,
                            icon: Icons.eco,
                            title: 'Eco-Friendly',
                            subtitle: 'Go Green, Go Digital',
                            description:
                                'Save trees and reduce waste by going paperless. Join thousands making environmentally conscious networking choices.',
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Log In',
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
    );
  }
}