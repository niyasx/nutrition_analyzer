import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/data/datasources/gemini_api_client.dart';
import 'package:nutrition_app/features/nutrition/data/datasources/local_storage_service.dart';
import 'package:nutrition_app/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:nutrition_app/features/nutrition/data/models/gemini_response_model.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';

class MockGeminiApiClient extends Mock implements GeminiApiClient {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late NutritionRepositoryImpl repository;
  late MockGeminiApiClient mockApiClient;
  late MockLocalStorageService mockLocalStorage;

  setUp(() {
    mockApiClient = MockGeminiApiClient();
    mockLocalStorage = MockLocalStorageService();
    repository = NutritionRepositoryImpl(
      apiClient: mockApiClient,
      localStorage: mockLocalStorage,
    );
  });

  group('analyzeImage', () {
    const imagePath = '/path/to/image.jpg';

    // Note: mockFoodItem not used; removed to silence lint

    test('returns AnalysisResult when API call succeeds', () async {
      // Arrange
      final mockResponse = GeminiResponseModel(
        candidates: [
          GeminiCandidate(
            content: GeminiContent(
              parts: [
                GeminiPart(
                  text: '{"foods":[{"name":"Apple","description":"Fresh red apple","confidence":0.95,"nutrition":{"calories":95,"protein":0.5,"carbs":25,"fat":0.3,"fiber":4,"sugar":19,"sodium":2,"micronutrients":{"vitamin_c":8.4},"serving_size":"1 medium (182g)"}}]}',
                ),
              ],
            ),
          ),
        ],
      );

      when(() => mockApiClient.mockAnalyzeImage(imagePath))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.analyzeImage(imagePath);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (analysisResult) {
          expect(analysisResult.foodItems.length, 1);
          expect(analysisResult.imagePath, imagePath);
        },
      );
      verify(() => mockApiClient.mockAnalyzeImage(imagePath)).called(1);
    });

    test('returns ServerFailure when API throws ServerException', () async {
      // Arrange
      when(() => mockApiClient.mockAnalyzeImage(imagePath))
          .thenThrow(ServerException(message: 'Server error'));

      // Act
      final result = await repository.analyzeImage(imagePath);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
        },
        (success) => fail('Should return Left'),
      );
    });

    test('returns NetworkFailure when API throws NetworkException', () async {
      // Arrange
      when(() => mockApiClient.mockAnalyzeImage(imagePath))
          .thenThrow(NetworkException(message: 'Network error'));

      // Act
      final result = await repository.analyzeImage(imagePath);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Network error');
        },
        (success) => fail('Should return Left'),
      );
    });
  });

  group('saveAnalysisResult', () {
    test('saves analysis result successfully', () async {
      // Arrange
      final mockResult = AnalysisResult(
        id: 'test-id',
        foodItems: [],
        imagePath: '/path/to/image.jpg',
        analyzedAt: DateTime.now(),
      );

      when(() => mockLocalStorage.saveAnalysisResult(mockResult))
          .thenAnswer((_) async => Future.value());

      // Act & Assert
      expect(
        () => repository.saveAnalysisResult(mockResult),
        returnsNormally,
      );
    });
  });

  group('getAnalysisHistory', () {
    test('returns list of analysis results', () async {
      // Arrange
      final mockResults = [
        AnalysisResult(
          id: 'test-1',
          foodItems: [],
          imagePath: '/path/1.jpg',
          analyzedAt: DateTime.now(),
        ),
        AnalysisResult(
          id: 'test-2',
          foodItems: [],
          imagePath: '/path/2.jpg',
          analyzedAt: DateTime.now(),
        ),
      ];

      when(() => mockLocalStorage.getAnalysisHistory())
          .thenAnswer((_) async => mockResults);

      // Act
      final result = await repository.getAnalysisHistory();

      // Assert
      expect(result.length, 2);
      verify(() => mockLocalStorage.getAnalysisHistory()).called(1);
    });
  });
}