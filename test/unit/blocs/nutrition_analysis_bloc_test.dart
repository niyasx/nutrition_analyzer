import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/food_item.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/nutrition_data.dart';
import 'package:nutrition_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:nutrition_app/features/nutrition/domain/usecases/analyze_image_usecase.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_state.dart';

class MockAnalyzeImageUseCase extends Mock implements AnalyzeImageUseCase {}
class MockNutritionRepository extends Mock implements NutritionRepository {}

void main() {
  late NutritionAnalysisBloc bloc;
  late MockAnalyzeImageUseCase mockAnalyzeImageUseCase;
  late MockNutritionRepository mockNutritionRepository;

  setUp(() {
    mockAnalyzeImageUseCase = MockAnalyzeImageUseCase();
    mockNutritionRepository = MockNutritionRepository();
    bloc = NutritionAnalysisBloc(
      analyzeImageUseCase: mockAnalyzeImageUseCase,
      nutritionRepository: mockNutritionRepository,
    );
  });

  group('NutritionAnalysisBloc', () {
    const imagePath = '/path/to/image.jpg';
    final mockResult = AnalysisResult(
      id: 'test-id',
      foodItems: [
        FoodItem(
          id: 'food-1',
          name: 'Apple',
          description: 'Fresh red apple',
          nutritionData: const NutritionData(
            calories: 95,
            protein: 0.5,
            carbs: 25,
            fat: 0.3,
            fiber: 4,
            sugar: 19,
            sodium: 2,
            micronutrients: {'vitamin_c': 8.4},
            servingSize: '1 medium (182g)',
          ),
          confidenceScore: 0.95,
          analyzedAt: DateTime.now(),
        ),
      ],
      imagePath: imagePath,
      analyzedAt: DateTime.now(),
    );

    test('initial state is NutritionAnalysisInitial', () {
      expect(bloc.state, equals(const NutritionAnalysisInitial()));
    });

    blocTest<NutritionAnalysisBloc, NutritionAnalysisState>(
      'emits [loading, success] when analysis succeeds',
      build: () {
        when(() => mockAnalyzeImageUseCase(imagePath))
            .thenAnswer((_) async => Right(mockResult));
        return bloc;
      },
      act: (bloc) => bloc.add(const AnalyzeImage(imagePath: imagePath)),
      expect: () => [
        const NutritionAnalysisLoading(),
        NutritionAnalysisSuccess(result: mockResult),
      ],
    );

    blocTest<NutritionAnalysisBloc, NutritionAnalysisState>(
      'emits [loading, error] when analysis fails',
      build: () {
        when(() => mockAnalyzeImageUseCase(imagePath))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'API Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AnalyzeImage(imagePath: imagePath)),
      expect: () => [
        const NutritionAnalysisLoading(),
        const NutritionAnalysisError(
          failure: ServerFailure(message: 'API Error'),
        ),
      ],
    );

    blocTest<NutritionAnalysisBloc, NutritionAnalysisState>(
      'updates portion size correctly',
      build: () => bloc,
      seed: () => NutritionAnalysisSuccess(result: mockResult),
      act: (bloc) => bloc.add(const UpdatePortionSize(
        foodItemId: 'food-1',
        portionMultiplier: 2.0,
      )),
      expect: () => [
        isA<NutritionAnalysisSuccess>().having(
          (state) => state.result.foodItems.first.portionMultiplier,
          'portion multiplier',
          2.0,
        ),
      ],
    );
  });
}