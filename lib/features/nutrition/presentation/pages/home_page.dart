import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_state.dart';
import 'package:nutrition_app/shared/widgets/responsive_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: const _MobileLayout(),
        tablet: const _TabletLayout(),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: DesignTokens.spaceXL),
            const _Header(),
            const SizedBox(height: DesignTokens.space2XL),
            const _ActionButtons(),
            const SizedBox(height: DesignTokens.space2XL),
            const _RecentAnalysisSection(),
          ],
        ),
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLG),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: DesignTokens.spaceXL),
                  const _Header(),
                  const SizedBox(height: DesignTokens.space2XL),
                  const _ActionButtons(),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spaceLG),
            const Expanded(
              flex: 3,
              child: _RecentAnalysisSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: DesignTokens.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 40,
            color: DesignTokens.primaryGreen,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        Text(
          'Nutrition Analyzer',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          'Snap a photo of your meal and get instant nutritional insights',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: DesignTokens.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _captureImage(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceLG),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _captureImage(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceLG),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        TextButton.icon(
          onPressed: () => context.go('/history'),
          icon: const Icon(Icons.history),
          label: const Text('View History'),
        ),
      ],
    );
  }

  Future<void> _captureImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null && context.mounted) {
      context.read<NutritionAnalysisBloc>().add(
            AnalyzeImage(imagePath: image.path),
          );
      context.go('/results');
    }
  }
}

class _RecentAnalysisSection extends StatelessWidget {
  const _RecentAnalysisSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoaded && state.results.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Analysis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              Expanded(
                child: ListView.separated(
                  itemCount: state.results.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.spaceSM),
                  itemBuilder: (context, index) {
                    final result = state.results[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: DesignTokens.primaryGreen.withOpacity(0.1),
                          child: const Icon(
                            Icons.fastfood,
                            color: DesignTokens.primaryGreen,
                          ),
                        ),
                        title: Text(
                          '${result.foodItems.length} food item${result.foodItems.length != 1 ? 's' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${result.totalNutrition.calories.toStringAsFixed(0)} calories',
                        ),
                        trailing: Text(
                          _formatDate(result.analyzedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => context.go('/history/${result.id}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              Text(
                'No analysis history yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: DesignTokens.spaceSM),
              Text(
                'Start by taking a photo of your meal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}