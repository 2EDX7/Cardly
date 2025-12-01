import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'presentation/theme/themes.dart';
import 'logic/cubits/theme/theme_cubit.dart';
import 'logic/cubits/theme/theme_state.dart';
import 'logic/cubits/card/card_cubit.dart';
import 'routes/routes.dart';
import 'data/database/database_helper.dart';

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
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Cardly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}