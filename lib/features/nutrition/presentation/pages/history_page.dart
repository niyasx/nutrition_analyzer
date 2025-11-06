import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_state.dart';
import 'package:nutrition_app/shared/widgets/error_widget.dart';
import 'package:nutrition_app/shared/widgets/responsive_layout.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HistoryBloc>().add(const RefreshHistory());
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HistoryLoaded) {
            if (state.results.isEmpty) {
              return const _EmptyHistoryWidget();
            }
            return ResponsiveLayout(
              mobile: _MobileHistoryList(results: state.results),
              tablet: _TabletHistoryGrid(results: state.results),
            );
          } else if (state is HistoryError) {
            return CustomErrorWidget(
              error: state.failure.message,
              onRetry: () {
                context.read<HistoryBloc>().add(const LoadHistory());
              },
            );
          }
          
          return const Center(child: Text('No history available'));
        },
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final String analysisId;

  const HistoryDetailPage({
    super.key,
    required this.analysisId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<HistoryBloc>()
        ..add(LoadAnalysisDetail(analysisId: analysisId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analysis Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/history'),
          ),
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryDetailLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Analysis details implementation would go here
                    Text(
                      'Analysis from ${_formatDate(state.result.analyzedAt)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: DesignTokens.spaceLG),
                    Text(
                      '${state.result.foodItems.length} food items detected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: DesignTokens.spaceMD),
                    Text(
                      'Total: ${state.result.totalNutrition.calories.toStringAsFixed(0)} calories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DesignTokens.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is HistoryError) {
              return CustomErrorWidget(
                error: state.failure.message,
                onRetry: () {
                  context.read<HistoryBloc>().add(
                    LoadAnalysisDetail(analysisId: analysisId),
                  );
                },
              );
            }
            
            return const Center(child: Text('Analysis not found'));
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _MobileHistoryList extends StatelessWidget {
  final List<dynamic> results;

  const _MobileHistoryList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.spaceSM),
      itemBuilder: (context, index) {
        final result = results[index];
        return _HistoryCard(result: result);
      },
    );
  }
}

class _TabletHistoryGrid extends StatelessWidget {
  final List<dynamic> results;

  const _TabletHistoryGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: DesignTokens.spaceMD,
          mainAxisSpacing: DesignTokens.spaceMD,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _HistoryCard(result: result);
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic result;

  const _HistoryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/history/${result.id}'),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: DesignTokens.primaryGreen.withOpacity(0.1),
                    child: Icon(
                      Icons.fastfood,
                      color: DesignTokens.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.foodItems.length} food item${result.foodItems.length != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          _formatDate(result.analyzedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: DesignTokens.error),
                            SizedBox(width: DesignTokens.spaceSM),
                            Text('Delete'),
                          ],
                        ),
                        onTap: () {
                          context.read<HistoryBloc>().add(
                            DeleteAnalysis(analysisId: result.id),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              const Divider(),
              const SizedBox(height: DesignTokens.spaceSM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NutritionBadge(
                    label: 'Calories',
                    value: result.totalNutrition.calories.toStringAsFixed(0),
                    color: DesignTokens.primaryGreen,
                  ),
                  _NutritionBadge(
                    label: 'Protein',
                    value: '${result.totalNutrition.protein.toStringAsFixed(1)}g',
                    color: Colors.blue,
                  ),
                  _NutritionBadge(
                    label: 'Carbs',
                    value: '${result.totalNutrition.carbs.toStringAsFixed(1)}g',
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _NutritionBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _EmptyHistoryWidget extends StatelessWidget {
  const _EmptyHistoryWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: DesignTokens.spaceMD),
            Text(
              'No analysis history yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Text(
              'Start analyzing your meals to see them here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceLG),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Analyze First Meal'),
            ),
          ],
        ),
      ),
    );
  }
}