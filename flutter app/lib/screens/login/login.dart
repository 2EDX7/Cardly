import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/colors.dart';
import '../../widgets/stars_background.dart';
import '../../theme/typography.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
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
                                'Sign in to your\nAccount',
                                style: AppTextStyles.heading1(context).copyWith(color: cs.onPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Enter your email and password to log in',
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
                                      'Continue with Google',
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
                                  child: Text('Or login with', style: AppTextStyles.caption(context)),
                                ),
                                Expanded(child: Divider(color: cs.onSurface.withAlpha(50))),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Email field
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Email',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Password field
                            TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
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
                                    Text('Remember me', style: AppTextStyles.caption(context)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTextStyles.bodySmall(context).copyWith(color: cs.primary),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.md),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text('Log In', style: AppTextStyles.buttonPrimary(context)),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ", style: AppTextStyles.caption(context)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
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
    );
  }
}