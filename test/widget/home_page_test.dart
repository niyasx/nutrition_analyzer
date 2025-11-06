import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrition_app/features/nutrition/presentation/pages/home_page.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_state.dart';

class MockNutritionAnalysisBloc extends Mock implements NutritionAnalysisBloc {}
class MockHistoryBloc extends Mock implements HistoryBloc {}

void main() {
  late MockNutritionAnalysisBloc mockNutritionAnalysisBloc;
  late MockHistoryBloc mockHistoryBloc;

  setUp(() {
    mockNutritionAnalysisBloc = MockNutritionAnalysisBloc();
    mockHistoryBloc = MockHistoryBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NutritionAnalysisBloc>.value(
            value: mockNutritionAnalysisBloc,
          ),
          BlocProvider<HistoryBloc>.value(
            value: mockHistoryBloc,
          ),
        ],
        child: const HomePage(),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('displays app title and description', (tester) async {
      when(() => mockHistoryBloc.state).thenReturn(
        const HistoryLoaded(results: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nutrition Analyzer'), findsOneWidget);
      expect(
        find.text('Snap a photo of your meal and get instant nutritional insights'),
        findsOneWidget,
      );
    });

    testWidgets('displays Take Photo button', (tester) async {
      when(() => mockHistoryBloc.state).thenReturn(
        const HistoryLoaded(results: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('displays Choose from Gallery button', (tester) async {
      when(() => mockHistoryBloc.state).thenReturn(
        const HistoryLoaded(results: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('displays View History button', (tester) async {
      when(() => mockHistoryBloc.state).thenReturn(
        const HistoryLoaded(results: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('View History'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows empty state when no history', (tester) async {
      when(() => mockHistoryBloc.state).thenReturn(
        const HistoryLoaded(results: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No analysis history yet'), findsOneWidget);
    });

    testWidgets('app icon is displayed', (tester) async {
      when(() => mockHistoryBloc.state).thenReturn(
        const HistoryLoaded(results: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });
  });
}