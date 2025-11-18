import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/data/datasources/gemini_api_client.dart';
import 'package:nutrition_app/features/nutrition/data/datasources/local_storage_service.dart';
import 'package:nutrition_app/features/nutrition/data/models/food_item_model.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/features/nutrition/domain/repositories/nutrition_repository.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final GeminiApiClient apiClient;
  final LocalStorageService localStorage;
  final Uuid _uuid = const Uuid();

  NutritionRepositoryImpl({
    required this.apiClient,
    required this.localStorage,
  });

  @override
  Future<Either<Failure, AnalysisResult>> analyzeImage(String imagePath) async {
    try {
      // Use real API call
      log('=== API CALL STARTED ===');
      log('Image path: $imagePath');
      final response = await apiClient.analyzeImage(imagePath);
      log('=== API RESPONSE RECEIVED ===');
      log('Response: ${response.toString()}');
      log('Food items count: ${response.foodItems.length}');
      for (var i = 0; i < response.foodItems.length; i++) {
        final item = response.foodItems[i];
        log('Food item $i: ${item.name} - Calories: ${item.nutritionData.calories}');
      }
      log('=== API CALL COMPLETED ===');
      
      final foodItems = response.foodItems
          .map((model) => FoodItemModel.fromGeminiJson({
                'name': model.name,
                'description': model.description,
                'confidence': model.confidenceScore,
                'nutrition': {
                  'calories': model.nutritionData.calories,
                  'protein': model.nutritionData.protein,
                  'carbs': model.nutritionData.carbs,
                  'fat': model.nutritionData.fat,
                  'fiber': model.nutritionData.fiber,
                  'sugar': model.nutritionData.sugar,
                  'sodium': model.nutritionData.sodium,
                  'micronutrients': model.nutritionData.micronutrients,
                  'serving_size': model.nutritionData.servingSize,
                }
              }))
          .toList();

      final result = AnalysisResult(
        id: _uuid.v4(),
        foodItems: foodItems,
        imagePath: imagePath,
        analyzedAt: DateTime.now(),
      );

      return Right(result);
    } on ValidationException catch (e) {
      log('Validation error: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      log('Server error: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log('Network error: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      log('Unexpected error: $e');
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {
    try {
      await localStorage.saveAnalysisResult(result);
      log('Analysis result saved: ${result.id}');
    } catch (e) {
      log('Failed to save analysis result: $e');
      throw CacheFailure(message: 'Failed to save analysis result');
    }
  }

  @override
  Future<List<AnalysisResult>> getAnalysisHistory() async {
    try {
      return await localStorage.getAnalysisHistory();
    } catch (e) {
      log('Failed to load analysis history: $e');
      throw CacheFailure(message: 'Failed to load analysis history');
    }
  }

  @override
  Future<AnalysisResult?> getAnalysisById(String id) async {
    try {
      return await localStorage.getAnalysisById(id);
    } catch (e) {
      log('Failed to load analysis: $e');
      throw CacheFailure(message: 'Failed to load analysis');
    }
  }

  @override
  Future<void> deleteAnalysis(String id) async {
    try {
      await localStorage.deleteAnalysis(id);
      log('Analysis deleted: $id');
    } catch (e) {
      log('Failed to delete analysis: $e');
      throw CacheFailure(message: 'Failed to delete analysis');
    }
  }
}