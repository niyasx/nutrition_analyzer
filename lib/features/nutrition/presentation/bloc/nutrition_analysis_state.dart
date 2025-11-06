import 'package:equatable/equatable.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/core/error/failures.dart';

abstract class NutritionAnalysisState extends Equatable {
  const NutritionAnalysisState();

  @override
  List<Object?> get props => [];
}

class NutritionAnalysisInitial extends NutritionAnalysisState {
  const NutritionAnalysisInitial();
}

class NutritionAnalysisLoading extends NutritionAnalysisState {
  const NutritionAnalysisLoading();
}

class NutritionAnalysisSuccess extends NutritionAnalysisState {
  final AnalysisResult result;

  const NutritionAnalysisSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

class NutritionAnalysisError extends NutritionAnalysisState {
  final Failure failure;

  const NutritionAnalysisError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class NutritionAnalysisSaved extends NutritionAnalysisState {
  final AnalysisResult result;

  const NutritionAnalysisSaved({required this.result});

  @override
  List<Object?> get props => [result];
}