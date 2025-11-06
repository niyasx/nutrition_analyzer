import 'package:equatable/equatable.dart';

abstract class NutritionAnalysisEvent extends Equatable {
  const NutritionAnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeImage extends NutritionAnalysisEvent {
  final String imagePath;

  const AnalyzeImage({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class UpdatePortionSize extends NutritionAnalysisEvent {
  final String foodItemId;
  final double portionMultiplier;

  const UpdatePortionSize({
    required this.foodItemId,
    required this.portionMultiplier,
  });

  @override
  List<Object?> get props => [foodItemId, portionMultiplier];
}

class ConfirmFoodItem extends NutritionAnalysisEvent {
  final String foodItemId;
  final bool isConfirmed;

  const ConfirmFoodItem({
    required this.foodItemId,
    required this.isConfirmed,
  });

  @override
  List<Object?> get props => [foodItemId, isConfirmed];
}

class SaveAnalysis extends NutritionAnalysisEvent {
  const SaveAnalysis();
}

class ResetAnalysis extends NutritionAnalysisEvent {
  const ResetAnalysis();
}