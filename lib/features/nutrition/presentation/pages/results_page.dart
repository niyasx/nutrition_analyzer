import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_state.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/widgets/loading_skeleton.dart';
import 'package:nutrition_app/features/nutrition/presentation/widgets/nutrition_card.dart';
import 'package:nutrition_app/features/nutrition/presentation/widgets/food_item_card.dart';
import 'package:nutrition_app/shared/widgets/error_widget.dart';
import 'package:nutrition_app/shared/widgets/responsive_layout.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          BlocBuilder<NutritionAnalysisBloc, NutritionAnalysisState>(
            builder: (context, state) {
              if (state is NutritionAnalysisSuccess ||
                  state is NutritionAnalysisSaved) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    context
                        .read<NutritionAnalysisBloc>()
                        .add(const SaveAnalysis());
                    // Refresh history after saving
                    context.read<HistoryBloc>().add(const RefreshHistory());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analysis saved!')),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NutritionAnalysisBloc, NutritionAnalysisState>(
        builder: (context, state) {
          if (state is NutritionAnalysisLoading) {
            return const LoadingSkeleton();
          } else if (state is NutritionAnalysisSuccess ||
              state is NutritionAnalysisSaved) {
            final analysisResult = state is NutritionAnalysisSuccess
                ? state.result
                : (state as NutritionAnalysisSaved).result;

            return ResponsiveLayout(
              mobile: _MobileResultsLayout(result: analysisResult),
              tablet: _TabletResultsLayout(result: analysisResult),
            );
          } else if (state is NutritionAnalysisError) {
            final failure = state.failure;
            String? title;
            IconData? icon;

            if (failure is ValidationFailure) {
              title = 'No food detected';
              icon = Icons.restaurant_outlined;
            } else if (failure is NetworkFailure) {
              title = 'Network issue';
              icon = Icons.wifi_off;
            } else if (failure is CacheFailure) {
              title = 'Save failed';
              icon = Icons.save_outlined;
            } else {
              title = 'Analysis unavailable';
              icon = Icons.cloud_off;
            }

            return CustomErrorWidget(
              error: failure.message,
              title: title,
              icon: icon,
              onRetry: () {
                context.read<NutritionAnalysisBloc>().add(const ResetAnalysis());
                context.go('/');
              },
            );
          }
          
          return const Center(
            child: Text('No analysis to show'),
          );
        },
      ),
    );
  }
}

class _MobileResultsLayout extends StatelessWidget {
  final dynamic result; // AnalysisResult

  const _MobileResultsLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageSection(imagePath: result.imagePath),
          const SizedBox(height: DesignTokens.spaceLG),
          NutritionCard(
            title: 'Total Nutrition',
            nutritionData: result.totalNutrition,
            isExpanded: true,
          ),
          const SizedBox(height: DesignTokens.spaceLG),
          _FoodItemsSection(foodItems: result.foodItems),
        ],
      ),
    );
  }
}

class _TabletResultsLayout extends StatelessWidget {
  final dynamic result; // AnalysisResult

  const _TabletResultsLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _ImageSection(imagePath: result.imagePath),
                const SizedBox(height: DesignTokens.spaceLG),
                NutritionCard(
                  title: 'Total Nutrition',
                  nutritionData: result.totalNutrition,
                  isExpanded: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spaceLG),
          Expanded(
            flex: 1,
            child: _FoodItemsSection(foodItems: result.foodItems),
          ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final String imagePath;

  const _ImageSection({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: DesignTokens.shadowMD,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FoodItemsSection extends StatelessWidget {
  final List<dynamic> foodItems; // List<FoodItem>

  const _FoodItemsSection({required this.foodItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Foods',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        ...foodItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
              child: FoodItemCard(
                foodItem: item,
                onPortionChanged: (multiplier) {
                  context.read<NutritionAnalysisBloc>().add(
                        UpdatePortionSize(
                          foodItemId: item.id,
                          portionMultiplier: multiplier,
                        ),
                      );
                },
              ),
            )),
      ],
    );
  }
}