import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/themes.dart';
import 'theme/theme_modifier.dart';
import 'theme/theme_demonstration.dart';
// import 'screens/addCard.dart';
// import 'screens/fillcardinformations.dart';
// import 'screens/addCardinformations.dart';
// import 'screens/ScanCard.dart';
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
          home: const ThemeDemonstration(),
          // routes: {
          //   '/': (context) => const ThemeDemonstration(),
          //   '/addCard': (context) => const AddCardScreen(),
          //   '/addCard/information': (context) => const Addcardinformations(),
          //   '/addCard/fillinformation': (context) => const FillCardInformationScreen(),
          //   '/addCard/ScanCard': (context) => const ScanCardScreen(),
          // },
          // initialRoute: '/addCard/ScanCard',
        );
      },
    );
  }
}