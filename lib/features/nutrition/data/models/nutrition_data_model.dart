import 'package:nutrition_app/features/nutrition/domain/entities/nutrition_data.dart';

class NutritionDataModel extends NutritionData {
  const NutritionDataModel({
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.fiber,
    required super.sugar,
    required super.sodium,
    required super.micronutrients,
    required super.servingSize,
  });

  factory NutritionDataModel.fromJson(Map<String, dynamic> json) {
    final micronutrientsJson = json['micronutrients'] as Map<String, dynamic>? ?? {};
    final micronutrients = <String, double>{};
    
    micronutrientsJson.forEach((key, value) {
      micronutrients[key] = (value as num?)?.toDouble() ?? 0.0;
    });

    return NutritionDataModel(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      micronutrients: micronutrients,
      servingSize: json['serving_size'] as String? ?? '100g',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'micronutrients': micronutrients,
      'serving_size': servingSize,
    };
  }

  factory NutritionDataModel.fromEntity(NutritionData entity) {
    return NutritionDataModel(
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
      fiber: entity.fiber,
      sugar: entity.sugar,
      sodium: entity.sodium,
      micronutrients: entity.micronutrients,
      servingSize: entity.servingSize,
    );
  }
}