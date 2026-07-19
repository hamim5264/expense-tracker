import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/common/utils/theme_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<ExpenseBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeService.themeModeNotifier,
        ThemeService.primaryColorNotifier,
      ]),
      builder: (context, _) {
        final primaryColor = ThemeService.primaryColorNotifier.value;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker',
          theme: AppTheme.lightThemeMode(primaryColor),
          darkTheme: AppTheme.darkThemeMode(primaryColor),
          themeMode: ThemeService.themeModeNotifier.value,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRouter.splash,
        );
      },
    );
  }
}
