
import 'package:dartz/dartz.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/features/nutrition/domain/repositories/nutrition_repository.dart';

class AnalyzeImageUseCase {
  final NutritionRepository repository;

  AnalyzeImageUseCase(this.repository);

  Future<Either<Failure, AnalysisResult>> call(String imagePath) async {
    return await repository.analyzeImage(imagePath);
  }
}