import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/features/nutrition/domain/usecases/analyze_image_usecase.dart';
import 'package:nutrition_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_state.dart';

class NutritionAnalysisBloc
    extends Bloc<NutritionAnalysisEvent, NutritionAnalysisState> {
  final AnalyzeImageUseCase _analyzeImageUseCase;
  final NutritionRepository _nutritionRepository;

  NutritionAnalysisBloc({
    required AnalyzeImageUseCase analyzeImageUseCase,
    required NutritionRepository nutritionRepository,
  })  : _analyzeImageUseCase = analyzeImageUseCase,
        _nutritionRepository = nutritionRepository,
        super(const NutritionAnalysisInitial()) {
    on<AnalyzeImage>(_onAnalyzeImage);
    on<UpdatePortionSize>(_onUpdatePortionSize);
    on<ConfirmFoodItem>(_onConfirmFoodItem);
    on<SaveAnalysis>(_onSaveAnalysis);
    on<ResetAnalysis>(_onResetAnalysis);
  }

  Future<void> _onAnalyzeImage(
    AnalyzeImage event,
    Emitter<NutritionAnalysisState> emit,
  ) async {
    try {
      emit(const NutritionAnalysisLoading());
      log('Starting image analysis for: ${event.imagePath}');

      final result = await _analyzeImageUseCase(event.imagePath);

      result.fold(
        (failure) {
          log('Analysis failed: ${failure.message}');
          emit(NutritionAnalysisError(failure: failure));
        },
        (analysisResult) {
          log('Analysis successful: ${analysisResult.foodItems.length} items found');
          emit(NutritionAnalysisSuccess(result: analysisResult));
        },
      );
    } catch (e) {
      log('Unexpected error during analysis: $e');
      emit(NutritionAnalysisError(
        failure: ServerFailure(message: 'Unexpected error occurred: $e'),
      ));
    }
  }

  Future<void> _onUpdatePortionSize(
    UpdatePortionSize event,
    Emitter<NutritionAnalysisState> emit,
  ) async {
    if (state is NutritionAnalysisSuccess) {
      final currentState = state as NutritionAnalysisSuccess;
      final updatedItems = currentState.result.foodItems.map((item) {
        if (item.id == event.foodItemId) {
          return item.copyWith(portionMultiplier: event.portionMultiplier);
        }
        return item;
      }).toList();

      final updatedResult = AnalysisResult(
        id: currentState.result.id,
        foodItems: updatedItems,
        imagePath: currentState.result.imagePath,
        analyzedAt: currentState.result.analyzedAt,
      );

      emit(NutritionAnalysisSuccess(result: updatedResult));
    }
  }

  Future<void> _onConfirmFoodItem(
    ConfirmFoodItem event,
    Emitter<NutritionAnalysisState> emit,
  ) async {
    // Implementation for confirming/rejecting detected food items
    // This would update the confidence or remove items from the result
    log('Food item confirmation: ${event.foodItemId} - ${event.isConfirmed}');
  }

  Future<void> _onSaveAnalysis(
    SaveAnalysis event,
    Emitter<NutritionAnalysisState> emit,
  ) async {
    if (state is NutritionAnalysisSuccess) {
      try {
        final currentState = state as NutritionAnalysisSuccess;
        await _nutritionRepository.saveAnalysisResult(currentState.result);
        emit(NutritionAnalysisSaved(result: currentState.result));
        log('Analysis saved successfully');
      } catch (e) {
        log('Failed to save analysis: $e');
        emit(NutritionAnalysisError(
          failure: CacheFailure(message: 'Failed to save analysis'),
        ));
      }
    }
  }

  Future<void> _onResetAnalysis(
    ResetAnalysis event,
    Emitter<NutritionAnalysisState> emit,
  ) async {
    emit(const NutritionAnalysisInitial());
  }
}