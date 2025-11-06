import 'package:dartz/dartz.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';

abstract class NutritionRepository {
  Future<Either<Failure, AnalysisResult>> analyzeImage(String imagePath);
  Future<void> saveAnalysisResult(AnalysisResult result);
  Future<List<AnalysisResult>> getAnalysisHistory();
  Future<AnalysisResult?> getAnalysisById(String id);
  Future<void> deleteAnalysis(String id);
}