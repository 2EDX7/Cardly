import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/themes.dart';
import 'theme/theme_modifier.dart';
import 'theme/theme_demonstration.dart';
import 'package:cardly/screens/addcard/addCard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModifier(),
      child: const CardlyApp(),
    ),
  );
}

/// Main application widget
class CardlyApp extends StatelessWidget {
  const CardlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModifier>(
      builder: (context, themeModifier, _) {
        return MaterialApp(
          title: 'Cardly - Design System Demo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeModifier.themeMode,
          home: const AddCardScreen(),
        );
      },
    );
  }
}