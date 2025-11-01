import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/colors.dart';
import '../../widgets/stars_background.dart';
import '../../theme/typography.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _birthDateController = TextEditingController();

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
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background with two colors
          Column(
            children: [
              // TOP HALF - Primary Color Background
              Expanded(
                child: StarsBackground(
                  backgroundColor: cs.primary,
                  starColor: Colors.white,
                  numberOfStars: 60,
                  child: Container(),
                ),
              ),
              // BOTTOM HALF - White Background
              Expanded(
                child: Container(color: cs.surface),
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
                              // Back arrow
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
                                'Create Account',
                                style: AppTextStyles.heading1(context).copyWith(color: cs.onPrimary),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: AppTextStyles.bodySmall(context).copyWith(
                                      color: cs.onPrimary.withOpacity(0.9),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Log In',
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
                          mainAxisSize: MainAxisSize.min,
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

                            // First & Last name row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(hintText: 'First name'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(hintText: 'Last name'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            TextFormField(
                              decoration: const InputDecoration(hintText: 'Email'),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Birth date with date picker
                            TextFormField(
                              controller: _birthDateController,
                              decoration: InputDecoration(
                                hintText: 'Birth date',
                                suffixIcon: Icon(Icons.calendar_today, color: cs.primary),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(hintText: 'Password'),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text('Sign Up', style: AppTextStyles.buttonPrimary(context)),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(child: Divider(color: cs.onSurface.withAlpha(50))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: Text('Or', style: AppTextStyles.caption(context)),
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
    );
  }
}