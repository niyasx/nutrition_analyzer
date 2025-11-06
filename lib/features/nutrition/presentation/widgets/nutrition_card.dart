import 'package:flutter/material.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/nutrition_data.dart';

class NutritionCard extends StatefulWidget {
  final String title;
  final NutritionData nutritionData;
  final bool isExpanded;
  final bool showMicronutrients;

  const NutritionCard({
    super.key,
    required this.title,
    required this.nutritionData,
    this.isExpanded = false,
    this.showMicronutrients = true,
  });

  @override
  State<NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<NutritionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.forward();
    }
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
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: DesignTokens.primaryGreen,
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    '${widget.nutritionData.calories.toStringAsFixed(0)} cal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: DesignTokens.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down),
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
                children: [
                  const Divider(),
                  const SizedBox(height: DesignTokens.spaceMD),
                  _buildMacronutrients(),
                  if (widget.showMicronutrients &&
                      widget.nutritionData.micronutrients.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spaceLG),
                    _buildMicronutrients(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macronutrients',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        Row(
          children: [
            Expanded(
              child: _NutrientItem(
                label: 'Protein',
                value: widget.nutritionData.protein,
                unit: 'g',
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: _NutrientItem(
                label: 'Carbs',
                value: widget.nutritionData.carbs,
                unit: 'g',
                color: Colors.orange,
              ),
            ),
            Expanded(
              child: _NutrientItem(
                label: 'Fat',
                value: widget.nutritionData.fat,
                unit: 'g',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        Row(
          children: [
            Expanded(
              child: _NutrientItem(
                label: 'Fiber',
                value: widget.nutritionData.fiber,
                unit: 'g',
                color: Colors.green,
              ),
            ),
            Expanded(
              child: _NutrientItem(
                label: 'Sugar',
                value: widget.nutritionData.sugar,
                unit: 'g',
                color: Colors.pink,
              ),
            ),
            Expanded(
              child: _NutrientItem(
                label: 'Sodium',
                value: widget.nutritionData.sodium,
                unit: 'mg',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMicronutrients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Micronutrients',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        Wrap(
          spacing: DesignTokens.spaceSM,
          runSpacing: DesignTokens.spaceSM,
          children: widget.nutritionData.micronutrients.entries
              .map((entry) => _MicronutrientChip(
                    label: _formatMicronutrientName(entry.key),
                    value: entry.value,
                    unit: _getMicronutrientUnit(entry.key),
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _formatMicronutrientName(String key) {
    return key
        .split('_')
        .map((word) => word.isEmpty 
            ? '' 
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _getMicronutrientUnit(String key) {
    // Common micronutrient units
    const vitaminUnits = ['vitamin_a', 'vitamin_c', 'vitamin_d', 'vitamin_e'];
    const mineralUnits = ['calcium', 'iron', 'magnesium', 'phosphorus', 'potassium', 'zinc'];
    
    if (vitaminUnits.contains(key.toLowerCase())) {
      return 'mg';
    } else if (mineralUnits.contains(key.toLowerCase())) {
      return 'mg';
    } else {
      return 'mcg';
    }
  }
}

class _NutrientItem extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _NutrientItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
          ),
          child: Center(
            child: Text(
              value.toStringAsFixed(value < 10 ? 1 : 0),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MicronutrientChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _MicronutrientChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSM,
        vertical: DesignTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        border: Border.all(
          color: DesignTokens.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}$unit',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DesignTokens.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}