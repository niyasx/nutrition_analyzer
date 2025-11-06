import 'package:flutter_test/flutter_test.dart';
import 'package:nutrition_app/features/nutrition/data/models/nutrition_data_model.dart';

void main() {
  group('NutritionDataModel', () {
    const mockJson = {
      'calories': 250.0,
      'protein': 20.0,
      'carbs': 30.0,
      'fat': 10.0,
      'fiber': 5.0,
      'sugar': 8.0,
      'sodium': 300.0,
      'micronutrients': {
        'vitamin_c': 15.0,
        'iron': 2.5,
      },
      'serving_size': '100g',
    };

    test('fromJson creates valid model', () {
      final model = NutritionDataModel.fromJson(mockJson);

      expect(model.calories, 250.0);
      expect(model.protein, 20.0);
      expect(model.carbs, 30.0);
      expect(model.fat, 10.0);
      expect(model.fiber, 5.0);
      expect(model.sugar, 8.0);
      expect(model.sodium, 300.0);
      expect(model.micronutrients['vitamin_c'], 15.0);
      expect(model.micronutrients['iron'], 2.5);
      expect(model.servingSize, '100g');
    });

    test('toJson creates valid JSON', () {
      const model = NutritionDataModel(
        calories: 250.0,
        protein: 20.0,
        carbs: 30.0,
        fat: 10.0,
        fiber: 5.0,
        sugar: 8.0,
        sodium: 300.0,
        micronutrients: {
          'vitamin_c': 15.0,
          'iron': 2.5,
        },
        servingSize: '100g',
      );

      final json = model.toJson();

      expect(json['calories'], 250.0);
      expect(json['protein'], 20.0);
      expect(json['carbs'], 30.0);
      expect(json['fat'], 10.0);
      expect(json['fiber'], 5.0);
      expect(json['sugar'], 8.0);
      expect(json['sodium'], 300.0);
      expect(json['micronutrients']['vitamin_c'], 15.0);
      expect(json['micronutrients']['iron'], 2.5);
      expect(json['serving_size'], '100g');
    });

    test('scaleByPortion correctly scales nutrition values', () {
      const model = NutritionDataModel(
        calories: 100.0,
        protein: 10.0,
        carbs: 20.0,
        fat: 5.0,
        fiber: 2.0,
        sugar: 4.0,
        sodium: 100.0,
        micronutrients: {
          'vitamin_c': 10.0,
        },
        servingSize: '100g',
      );

      final scaled = model.scaleByPortion(2.0);

      expect(scaled.calories, 200.0);
      expect(scaled.protein, 20.0);
      expect(scaled.carbs, 40.0);
      expect(scaled.fat, 10.0);
      expect(scaled.fiber, 4.0);
      expect(scaled.sugar, 8.0);
      expect(scaled.sodium, 200.0);
      expect(scaled.micronutrients['vitamin_c'], 20.0);
      expect(scaled.servingSize, '100g'); // Serving size doesn't scale
    });

    test('handles missing micronutrients', () {
      final jsonWithoutMicro = {
        'calories': 250.0,
        'protein': 20.0,
        'carbs': 30.0,
        'fat': 10.0,
        'fiber': 5.0,
        'sugar': 8.0,
        'sodium': 300.0,
        'serving_size': '100g',
      };

      final model = NutritionDataModel.fromJson(jsonWithoutMicro);

      expect(model.micronutrients, isEmpty);
    });

    test('handles null values gracefully', () {
      final jsonWithNulls = {
        'calories': null,
        'protein': null,
        'carbs': 30.0,
        'fat': 10.0,
        'fiber': 5.0,
        'sugar': 8.0,
        'sodium': 300.0,
        'serving_size': '100g',
      };

      final model = NutritionDataModel.fromJson(jsonWithNulls);

      expect(model.calories, 0.0);
      expect(model.protein, 0.0);
      expect(model.carbs, 30.0);
    });
  });
}