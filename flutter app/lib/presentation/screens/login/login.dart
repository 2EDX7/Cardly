import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../widgets/stars_background.dart';
import '../../theme/typography.dart';
import '../../../routes/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/auth/auth_state.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/profile_card/profile_card_cubit.dart';
import '../../../logic/cubits/theme/theme_cubit.dart';
import '../../../logic/cubits/language/language_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginSuccess(BuildContext context, dynamic user) async {
    debugPrint('🔐 LOGIN SUCCESS - User: ${user.email}');
    debugPrint('🎴 User Card Data: name=${user.cardName}, bg=${user.cardBackground}, fontColor=${user.cardFontColor}');
    
    // Set user context
    context.read<CardCubit>().setUser(user.id);
    context.read<ProfileCardCubit>().setUser(user.id);
    
    
    // Load user preferences for theme and language
    final themeMode = ThemeCubit.themeModeFromString(user.themeMode);
    final locale = LanguageCubit.localeFromString(user.language);
    
    await context.read<ThemeCubit>().setUser(user.id, initialTheme: themeMode);
    await context.read<LanguageCubit>().setUser(user.id, initialLocale: locale);
    
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.main,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final authState = context.watch<AuthCubit>().state;
    final isLoading = authState.status == AuthStatus.loading;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          final user = state.user!;
          
          // Load user data and preferences
          _handleLoginSuccess(context, user);
        } else if (state.status == AuthStatus.error && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              // TOP HALF - Primary Color Background
              Expanded(
                child: StarsBackground(
                  backgroundColor: cs.primary,
                  starColor: Colors.white,
                  numberOfStars: 40,
                  child: Container(),
                ),
              ),
              // BOTTOM HALF - White Background
              Expanded(
                child: Container(color: cs.background),
              ),
            ],
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header section - Hides when keyboard is visible
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: keyboardVisible ? 0 : null,
                  child: keyboardVisible
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              // Back button
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(Icons.arrow_back, color: cs.onPrimary),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Icon(Icons.shield, color: cs.onPrimary, size: 48),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                l10n.signInToAccount,
                                style: AppTextStyles.heading1(context).copyWith(color: cs.onPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l10n.enterEmailPassword,
                                style: AppTextStyles.body(context).copyWith(
                                  color: cs.onPrimary.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                ),

                // Form Card - Moves up when keyboard is visible
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: keyboardVisible ? AppSpacing.md : 0,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            // Back button for keyboard mode
                            if (keyboardVisible)
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            if (keyboardVisible) const SizedBox(height: AppSpacing.sm),

                            // Google button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: cs.onSurface.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                    horizontal: AppSpacing.md,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/google_icon.jpg', height: 20),
                                    const SizedBox(width: AppSpacing.md),
                                    Text(
                                      l10n.continueWithGoogle,
                                      style: AppTextStyles.body(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(child: Divider(color: cs.onSurface.withAlpha(50))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                  child: Text(l10n.orLoginWith, style: AppTextStyles.caption(context)),
                                ),
                                Expanded(child: Divider(color: cs.onSurface.withAlpha(50))),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: l10n.emailLabel,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: l10n.passwordLabel,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Remember Me Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: cs.primary,
                                      checkColor: Colors.white,
                                    ),
                                    Text(l10n.rememberMe, style: AppTextStyles.caption(context)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: AppTextStyles.bodySmall(context).copyWith(color: cs.primary),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.md),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        final email = _emailController.text.trim();
                                        final password = _passwordController.text;
                                        if (email.isEmpty || password.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(l10n.pleaseEnterEmail)),
                                          );
                                          return;
                                        }
                                        context.read<AuthCubit>().login(email: email, password: password);
                                      },
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(l10n.logIn, style: AppTextStyles.buttonPrimary(context)),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.dontHaveAccount + ' ', style: AppTextStyles.caption(context)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AppRoutes.signup);
                                  },
                                  child: Text(
                                    l10n.signUp,
                                    style: AppTextStyles.bodySmall(context).copyWith(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}