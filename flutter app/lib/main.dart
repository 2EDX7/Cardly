import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Theme & Localization
import 'presentation/theme/themes.dart';
import 'logic/cubits/theme/theme_cubit.dart';
import 'logic/cubits/theme/theme_state.dart';
import 'logic/cubits/language/language_cubit.dart';
import 'logic/cubits/language/language_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// Cubits
import 'logic/cubits/auth/auth_cubit.dart';
import 'logic/cubits/card/card_cubit.dart';
import 'logic/cubits/profile_card/profile_card_cubit.dart';

// API
import 'data/api/api_client.dart';
import 'data/services/token_storage_service.dart';
import 'data/services/notification_service.dart';
import 'data/repositories/api_user_repository.dart';
import 'data/repositories/api_card_repository.dart';
import 'data/repositories/api_profile_card_repository.dart';
import 'core/config/app_config.dart';

// Routes
import 'routes/routes.dart';

// Database (for theme & language persistence - can be removed if not needed)
import 'data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');

    // Initialize notification service
    await NotificationService().initialize();

    // Initialize HydratedBloc for state persistence
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );

    // Initialize SQLite database (kept for theme/language preferences)
    // Can be removed if you want to store preferences in API only
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
    // Initialize API client and repositories
    final apiClient = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      client: http.Client(),
      timeout: AppConfig.apiTimeout,
    );

    final tokenStorage = TokenStorageService();

    // Initialize repositories
    final userRepository = ApiUserRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    final cardRepository = ApiCardRepository(
      apiClient: apiClient,
    );

    final profileCardRepository = ApiProfileCardRepository(
      apiClient: apiClient,
    );

    // Restore token if exists
    _restoreAuthToken(apiClient, tokenStorage);

    final dbHelper = DatabaseHelper();

    return FutureBuilder<void>(
      future: _restoreAuthToken(apiClient, tokenStorage),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(repository: userRepository),
            ),
            BlocProvider(
              create: (context) => ThemeCubit(
                dbHelper: dbHelper,
                userRepository: userRepository,
                userId: null,
              ),
            ),
            BlocProvider(
              create: (context) => CardCubit(
                repository: cardRepository,
                initialUserId: null,
              ),
            ),
            BlocProvider(
              create: (context) => ProfileCardCubit(
                repository: profileCardRepository,
                initialUserId: null,
              ),
            ),
            BlocProvider(
              create: (context) => LanguageCubit(
                dbHelper: dbHelper,
                userRepository: userRepository,
                userId: null,
              ),
            ),
          ],
          child: BlocBuilder<AuthCubit, dynamic>(
            builder: (context, authState) {
              if (authState.user != null) {
                final userId = authState.user.id;
                Future.microtask(() {
                  try {
                    context.read<CardCubit>().setUser(userId);
                    context.read<ProfileCardCubit>().setUser(userId);
                    context.read<ThemeCubit>().setUser(userId);
                    context.read<LanguageCubit>().setUser(userId);
                  } catch (e) {
                    debugPrint('Error setting user context: $e');
                  }
                });
              }

              return BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, languageState) {
                      return MaterialApp(
                        title: 'Cardly',
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        supportedLocales: const [
                          Locale('en'),
                          Locale('fr'),
                          Locale('ar'),
                        ],
                        locale: languageState.locale,
                        localeResolutionCallback: (locale, supportedLocales) {
                          for (var supportedLocale in supportedLocales) {
                            if (supportedLocale.languageCode ==
                                locale?.languageCode) {
                              return supportedLocale;
                            }
                          }
                          return supportedLocales.first;
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
              );
            },
          ),
        );
      },
    );
  }

  /// Restore auth token from secure storage if exists
  Future<void> _restoreAuthToken(
      ApiClient apiClient, TokenStorageService tokenStorage) async {
    try {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        apiClient.setToken(token);
        debugPrint('✅ Restored auth token');
      }
    } catch (e) {
      debugPrint('Error restoring token: $e');
    }
  }
}
