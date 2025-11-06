import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/features/nutrition/data/models/food_item_model.dart';

class LocalStorageService {
  static const String _analysisBoxName = 'analysis_results';
  Box<Map<dynamic, dynamic>>? _analysisBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _analysisBox = await Hive.openBox<Map<dynamic, dynamic>>(_analysisBoxName);
    log('Local storage initialized');
  }

  Future<void> saveAnalysisResult(AnalysisResult result) async {
    try {
      final resultData = {
        'id': result.id,
        'image_path': result.imagePath,
        'analyzed_at': result.analyzedAt.toIso8601String(),
        'food_items': result.foodItems
            .map((item) => FoodItemModel.fromEntity(item).toJson())
            .toList(),
      };

      await _analysisBox?.put(result.id, resultData);
      log('Analysis result saved to local storage: ${result.id}');
    } catch (e) {
      log('Error saving analysis result: $e');
      rethrow;
    }
  }

  Future<List<AnalysisResult>> getAnalysisHistory() async {
    try {
      final results = <AnalysisResult>[];
      final keys = _analysisBox?.keys.toList() ?? [];

      for (final key in keys) {
        final data = _analysisBox?.get(key);
        if (data != null) {
          final result = _mapToAnalysisResult(data);
          if (result != null) {
            results.add(result);
          }
        }
      }

      // Sort by analyzed date (most recent first)
      results.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      return results;
    } catch (e) {
      log('Error loading analysis history: $e');
      return [];
    }
  }

  Future<AnalysisResult?> getAnalysisById(String id) async {
    try {
      final data = _analysisBox?.get(id);
      if (data != null) {
        return _mapToAnalysisResult(data);
      }
      return null;
    } catch (e) {
      log('Error loading analysis by ID: $e');
      return null;
    }
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      await _analysisBox?.delete(id);
      log('Analysis deleted from local storage: $id');
    } catch (e) {
      log('Error deleting analysis: $e');
      rethrow;
    }
  }

  AnalysisResult? _mapToAnalysisResult(Map<dynamic, dynamic> data) {
    try {
      final foodItemsData = data['food_items'] as List<dynamic>? ?? [];
      final foodItems = foodItemsData
          .map((itemData) => FoodItemModel.fromJson(
              Map<String, dynamic>.from(itemData as Map)))
          .toList();

      return AnalysisResult(
        id: data['id'] as String,
        foodItems: foodItems,
        imagePath: data['image_path'] as String,
        analyzedAt: DateTime.parse(data['analyzed_at'] as String),
      );
    } catch (e) {
      log('Error mapping analysis result: $e');
      return null;
    }
  }
}