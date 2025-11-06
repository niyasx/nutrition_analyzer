import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:nutrition_app/features/nutrition/data/datasources/gemini_api_client.dart';
import 'package:nutrition_app/features/nutrition/data/datasources/local_storage_service.dart';
import 'package:nutrition_app/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:nutrition_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:nutrition_app/features/nutrition/domain/usecases/analyze_image_usecase.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => Dio());
  
  // Data sources
  sl.registerLazySingleton<GeminiApiClient>(
    () => GeminiApiClient(dio: sl()),
  );
  
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );

  // Repositories
  sl.registerLazySingleton<NutritionRepository>(
    () => NutritionRepositoryImpl(
      apiClient: sl(),
      localStorage: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AnalyzeImageUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => NutritionAnalysisBloc(
        analyzeImageUseCase: sl(),
        nutritionRepository: sl(),
      ));
      
  sl.registerFactory(() => HistoryBloc(nutritionRepository: sl()));
  
  // Initialize local storage
  await sl<LocalStorageService>().init();
}