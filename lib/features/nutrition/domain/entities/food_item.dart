import 'package:equatable/equatable.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/nutrition_data.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final NutritionData nutritionData;
  final double confidenceScore;
  final double portionMultiplier;
  final DateTime analyzedAt;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.nutritionData,
    required this.confidenceScore,
    this.portionMultiplier = 1.0,
    required this.analyzedAt,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    NutritionData? nutritionData,
    double? confidenceScore,
    double? portionMultiplier,
    DateTime? analyzedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nutritionData: nutritionData ?? this.nutritionData,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      portionMultiplier: portionMultiplier ?? this.portionMultiplier,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  NutritionData get adjustedNutrition =>
      nutritionData.scaleByPortion(portionMultiplier);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        nutritionData,
        confidenceScore,
        portionMultiplier,
        analyzedAt,
      ];
}