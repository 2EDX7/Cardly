import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'presentation/theme/themes.dart';
import 'logic/cubits/theme/theme_cubit.dart';
import 'logic/cubits/theme/theme_state.dart';
import 'logic/cubits/card/card_cubit.dart';
import 'logic/cubits/language/language_cubit.dart';
import 'logic/cubits/language/language_state.dart';
import 'routes/routes.dart';
import 'data/database/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize HydratedBloc for state persistence
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
    
    // Initialize SQLite database
    await DatabaseHelper().database;
  } catch (e) {
    // Log error but continue - app can still run without persistence
    debugPrint('Error initializing storage: $e');
  }
  
  runApp(const CardlyApp());
}

/// Main application widget
class CardlyApp extends StatelessWidget {
  const CardlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => CardCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: 'Cardly',
                debugShowCheckedModeBanner: false,
                
                // Localization delegates
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                
                // Supported locales
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('fr'), // French
                  Locale('ar'), // Arabic
                ],
                
                // Current locale
                locale: languageState.locale,
                
                // Locale resolution callback
                localeResolutionCallback: (locale, supportedLocales) {
                  // Check if the current device locale is supported
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale?.languageCode) {
                      return supportedLocale;
                    }
                  }
                  // If not supported, return English as default
                  return supportedLocales.last;
                },
                
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: RouteGenerator.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}