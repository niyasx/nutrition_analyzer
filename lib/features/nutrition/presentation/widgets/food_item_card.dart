import 'package:flutter/material.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/food_item.dart';
import 'package:nutrition_app/features/nutrition/presentation/widgets/portion_slider.dart';
import 'package:nutrition_app/features/nutrition/presentation/widgets/confidence_indicator.dart';

class FoodItemCard extends StatefulWidget {
  final FoodItem foodItem;
  final Function(double) onPortionChanged;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.onPortionChanged,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adjustedNutrition = widget.foodItem.adjustedNutrition;

    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                        ),
                        child: const Icon(
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
                              widget.foodItem.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (widget.foodItem.description.isNotEmpty) ...[
                              const SizedBox(height: DesignTokens.spaceXS),
                              Text(
                                widget.foodItem.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: DesignTokens.textSecondary,
                                    ),
                              ),
                            ],
                            const SizedBox(height: DesignTokens.spaceSM),
                            Row(
                              children: [
                                ConfidenceIndicator(
                                  confidence: widget.foodItem.confidenceScore,
                                ),
                                const Spacer(),
                                Text(
                                  '${adjustedNutrition.calories.toStringAsFixed(0)} cal',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: DesignTokens.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: DesignTokens.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMD,
                0,
                DesignTokens.spaceMD,
                DesignTokens.spaceMD,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: DesignTokens.spaceMD),
                  PortionSlider(
                    initialValue: widget.foodItem.portionMultiplier,
                    servingSize: widget.foodItem.nutritionData.servingSize,
                    onChanged: widget.onPortionChanged,
                  ),
                  const SizedBox(height: DesignTokens.spaceLG),
                  _buildNutritionSummary(adjustedNutrition),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(dynamic nutritionData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Summary',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutrientColumn('Protein', nutritionData.protein, 'g', Colors.blue),
            _buildNutrientColumn('Carbs', nutritionData.carbs, 'g', Colors.orange),
            _buildNutrientColumn('Fat', nutritionData.fat, 'g', Colors.purple),
            _buildNutrientColumn('Fiber', nutritionData.fiber, 'g', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientColumn(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
          ),
          child: Center(
            child: Text(
              value.toStringAsFixed(value < 10 ? 1 : 0),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.textSecondary,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}