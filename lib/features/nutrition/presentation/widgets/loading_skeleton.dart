import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _stepTimer;
  int _currentStep = 0;

  static const List<String> _steps = [
    'Uploading photo',
    'Analyzing food items',
    'Preparing nutrition summary',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

    _stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < _steps.length - 1) {
          _currentStep++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.analytics,
                  size: 48,
                  color: DesignTokens.primaryGreen,
                ),
                const SizedBox(height: DesignTokens.spaceMD),
                Text(
                  'Analyzing your meal...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: DesignTokens.spaceSM),
                Text(
                  'This may take a few seconds',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space2XL),

          // Progress steps
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isActive = index == _currentStep;
              final Color color = isCompleted || isActive
                  ? DesignTokens.primaryGreen
                  : Colors.grey;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: DesignTokens.spaceSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isActive
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: DesignTokens.spaceSM),
                    Expanded(
                      child: Text(
                        _steps[index],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          
          // Image placeholder
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300.withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                ),
              );
            },
          ),
          const SizedBox(height: DesignTokens.spaceLG),
          
          // Cards placeholders
          ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300.withValues(alpha: _animation.value),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.spaceMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 16,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300.withValues(alpha: _animation.value),
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                                        ),
                                      ),
                                      const SizedBox(height: DesignTokens.spaceSM),
                                      Container(
                                        height: 12,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300.withValues(alpha: _animation.value),
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(4, (i) => Container(
                                    width: 60,
                                    height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300.withValues(alpha: _animation.value),
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
          
          const SizedBox(height: DesignTokens.spaceLG),
          const LinearProgressIndicator(
            color: DesignTokens.primaryGreen,
            backgroundColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}