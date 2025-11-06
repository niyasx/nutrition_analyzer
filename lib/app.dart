import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrition_app/core/di/injection.dart' as di;
import 'package:nutrition_app/core/routing/app_routes.dart';
import 'package:nutrition_app/core/theme/app_theme.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_event.dart';

class NutritionApp extends StatelessWidget {
  const NutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<NutritionAnalysisBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<HistoryBloc>()..add(const LoadHistory()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Nutrition Analyzer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}