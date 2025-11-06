import 'package:nutrition_app/features/nutrition/data/models/nutrition_data_model.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/food_item.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.nutritionData,
    required super.confidenceScore,
    super.portionMultiplier,
    required super.analyzedAt,
  });

  factory FoodItemModel.fromGeminiJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
      name: json['name'] as String? ?? 'Unknown Food',
      description: json['description'] as String? ?? '',
      nutritionData: NutritionDataModel.fromJson(
        json['nutrition'] as Map<String, dynamic>? ?? {},
      ),
      confidenceScore: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      portionMultiplier: 1.0,
      analyzedAt: DateTime.now(),
    );
  }

  factory FoodItemModel.fromEntity(FoodItem entity) {
    return FoodItemModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      nutritionData: entity.nutritionData,
      confidenceScore: entity.confidenceScore,
      portionMultiplier: entity.portionMultiplier,
      analyzedAt: entity.analyzedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'nutrition_data': (nutritionData as NutritionDataModel).toJson(),
      'confidence_score': confidenceScore,
      'portion_multiplier': portionMultiplier,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      nutritionData: NutritionDataModel.fromJson(
        json['nutrition_data'] as Map<String, dynamic>,
      ),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      portionMultiplier: (json['portion_multiplier'] as num?)?.toDouble() ?? 1.0,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );
  }
}