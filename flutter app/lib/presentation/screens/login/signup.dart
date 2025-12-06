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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: cs.primary,
              onPrimary: cs.onPrimary,
              surface: cs.surface,
              onSurface: cs.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUpSuccess(BuildContext context, dynamic user) async {
    // Set user context
    context.read<CardCubit>().setUser(user.id);
    
    // Load card data from user object (new users won't have card data)
    context.read<ProfileCardCubit>().loadCardFromUser(user);
    
    // For new users, use default preferences (already in User model)
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
          _handleSignUpSuccess(context, state.user!);
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
                Expanded(
                  child: StarsBackground(
                    backgroundColor: cs.primary,
                    starColor: Colors.white,
                    numberOfStars: 60,
                    child: Container(),
                  ),
                ),
                Expanded(
                  child: Container(color: cs.surface),
                ),
              ],
            ),
            SafeArea(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: keyboardVisible ? 0 : null,
                    child: keyboardVisible
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: Icon(Icons.arrow_back, color: cs.onPrimary),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                const SizedBox(height: AppSpacing.xxl),
                                Text(
                                  l10n.createAccount,
                                  style: AppTextStyles.heading1(context).copyWith(color: cs.onPrimary),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.alreadyHaveAccount,
                                      style: AppTextStyles.bodySmall(context).copyWith(
                                        color: cs.onPrimary.withOpacity(0.9),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Text(
                                        l10n.logIn,
                                        style: AppTextStyles.bodySmall(context).copyWith(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],
                            ),
                          ),
                  ),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      decoration: InputDecoration(hintText: l10n.firstName),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      decoration: InputDecoration(hintText: l10n.lastName),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(hintText: l10n.emailLabel),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _birthDateController,
                                decoration: InputDecoration(
                                  hintText: l10n.birthDate,
                                  suffixIcon: Icon(Icons.calendar_today, color: cs.primary),
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(hintText: l10n.passwordLabel),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
                                          final email = _emailController.text.trim();
                                          final password = _passwordController.text;
                                          if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(l10n.pleaseFillAllRequiredFields)),
                                            );
                                            return;
                                          }
                                          context.read<AuthCubit>().signUp(
                                                fullName: fullName,
                                                email: email,
                                                password: password,
                                              );
                                        },
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(l10n.signUp, style: AppTextStyles.buttonPrimary(context)),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: cs.onSurface.withAlpha(50))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                    child: Text(l10n.or, style: AppTextStyles.caption(context)),
                                  ),
                                  Expanded(child: Divider(color: cs.onSurface.withAlpha(50))),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
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
                                        'Continue with Google',
                                        style: AppTextStyles.body(context),
                                      ),
                                    ],
                                  ),
                                ),
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