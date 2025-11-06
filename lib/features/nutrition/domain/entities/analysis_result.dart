import 'package:equatable/equatable.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/food_item.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/nutrition_data.dart';

class AnalysisResult extends Equatable {
  final String id;
  final List<FoodItem> foodItems;
  final String imagePath;
  final DateTime analyzedAt;

  const AnalysisResult({
    required this.id,
    required this.foodItems,
    required this.imagePath,
    required this.analyzedAt,
  });

  NutritionData get totalNutrition {
    if (foodItems.isEmpty) {
      return const NutritionData(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        fiber: 0,
        sugar: 0,
        sodium: 0,
        micronutrients: {},
        servingSize: '0g',
      );
    }

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;
    Map<String, double> totalMicronutrients = {};

    for (final item in foodItems) {
      final nutrition = item.adjustedNutrition;
      totalCalories += nutrition.calories;
      totalProtein += nutrition.protein;
      totalCarbs += nutrition.carbs;
      totalFat += nutrition.fat;
      totalFiber += nutrition.fiber;
      totalSugar += nutrition.sugar;
      totalSodium += nutrition.sodium;

      nutrition.micronutrients.forEach((key, value) {
        totalMicronutrients[key] = (totalMicronutrients[key] ?? 0) + value;
      });
    }

    return NutritionData(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
      micronutrients: totalMicronutrients,
      servingSize: 'Total meal',
    );
  }

  @override
  List<Object?> get props => [id, foodItems, imagePath, analyzedAt];
}