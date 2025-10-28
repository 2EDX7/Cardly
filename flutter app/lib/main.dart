import 'package:flutter/material.dart';
import 'package:cardly/theme/colors.dart';
import 'package:cardly/theme/themes.dart';
import 'package:cardly/theme/typography.dart';

void main() {
  runApp(const CardlyApp());
}

class CardlyApp extends StatelessWidget {
  const CardlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // 🌞 Light mode
      darkTheme: AppTheme.darkTheme, // 🌙 Dark mode
      themeMode: ThemeMode.light, // 👈 Auto switch based on system
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface, // ✅ dynamic background from theme
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          'Cardly',
          style: textTheme.headlineMedium?.copyWith(color: colors.onPrimary),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cardly', style: AppTextStyles.heading1(context)),
              const SizedBox(height: 8),
              Text(
                'Your digital business card, simplified.',
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.buttonPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Already have an account?',
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
