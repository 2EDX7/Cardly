import 'package:flutter/material.dart';
import '../presentation/screens/login/splash.dart';
import '../presentation/screens/login/login.dart';
import '../presentation/screens/login/signup.dart';
import '../presentation/screens/addcard/fillcardinformations.dart';
import '../presentation/screens/addcard/ScanCard.dart';
import '../presentation/screens/addcard/addCardinformations.dart';
import '../presentation/screens/profile/edit_card_page.dart';
import '../data/models/card_info.dart';
import 'main_wrapper.dart';

/// Application route names
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  
  // Main app routes (with bottom nav)
  static const String main = '/main';
  static const String home = '/home';
  static const String addCard = '/add-card';
  static const String profile = '/profile';
  
  // Sub-routes (full screen)
  static const String fillCardManually = '/fill-card-manually';
  static const String scanCard = '/scan-card';
  static const String addCardInformations = '/add-card-informations';
  static const String editCard = '/edit-card';
}

/// Route generator for the application
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const IntroSplash());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      
      // Main wrapper with bottom navigation
      case AppRoutes.main:
        final int initialIndex = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => MainWrapper(initialIndex: initialIndex),
        );
      
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainWrapper(initialIndex: 0),
        );
      
      case AppRoutes.addCard:
        return MaterialPageRoute(
          builder: (_) => const MainWrapper(initialIndex: 1),
        );
      
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const MainWrapper(initialIndex: 2),
        );
      
      // Sub-routes
      case AppRoutes.fillCardManually:
        return MaterialPageRoute(builder: (_) => const Fillcardinformations());
      
      case AppRoutes.scanCard:
        return MaterialPageRoute(builder: (_) => const ScanCardScreen());
      
      case AppRoutes.addCardInformations:
        return MaterialPageRoute(builder: (_) => const Addcardinformations());
      
      case AppRoutes.editCard:
        // Extract CardInfo from arguments if provided
        final cardInfo = settings.arguments as CardInfo?;
        if (cardInfo == null) {
          return _errorRoute('CardInfo argument is required for edit card route');
        }
        return MaterialPageRoute(builder: (_) => EditCardPage(cardInfo: cardInfo));
      
      default:
        return _errorRoute();
    }
  }
  
  static Route<dynamic> _errorRoute([String? message]) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(message ?? 'Route not found'),
        ),
      ),
    );
  }
}
