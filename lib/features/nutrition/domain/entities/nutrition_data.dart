import 'package:equatable/equatable.dart';

class NutritionData extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final Map<String, double> micronutrients;
  final String servingSize;

  const NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.micronutrients,
    required this.servingSize,
  });

  NutritionData scaleByPortion(double multiplier) {
    return NutritionData(
      calories: calories * multiplier,
      protein: protein * multiplier,
      carbs: carbs * multiplier,
      fat: fat * multiplier,
      fiber: fiber * multiplier,
      sugar: sugar * multiplier,
      sodium: sodium * multiplier,
      micronutrients: micronutrients.map(
        (key, value) => MapEntry(key, value * multiplier),
      ),
      servingSize: servingSize, // Keep original serving size reference
    );
  }

  @override
  List<Object?> get props => [
        calories,
        protein,
        carbs,
        fat,
        fiber,
        sugar,
        sodium,
        micronutrients,
        servingSize,
      ];
}