import 'package:flutter/material.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';

class PortionSlider extends StatefulWidget {
  final double initialValue;
  final String servingSize;
  final Function(double) onChanged;
  final double min;
  final double max;

  const PortionSlider({
    super.key,
    required this.initialValue,
    required this.servingSize,
    required this.onChanged,
    this.min = 0.1,
    this.max = 5.0,
  });

  @override
  State<PortionSlider> createState() => _PortionSliderState();
}

class _PortionSliderState extends State<PortionSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portion Size',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceSM,
                vertical: DesignTokens.spaceXS,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Text(
                '${(_currentValue * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DesignTokens.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: DesignTokens.primaryGreen,
                  inactiveTrackColor: DesignTokens.primaryGreen.withValues(alpha: 0.2),
                  thumbColor: DesignTokens.primaryGreen,
                  overlayColor: DesignTokens.primaryGreen.withValues(alpha: 0.1),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: _currentValue,
                  min: widget.min,
                  max: widget.max,
                  divisions: 49, // 0.1 to 5.0 in 0.1 increments
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                    widget.onChanged(value);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Base: ${widget.servingSize}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
            ),
            Text(
              'Current: ${_getAdjustedServingSize()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  String _getAdjustedServingSize() {
    // Simple approach: multiply any numbers found in serving size
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    return widget.servingSize.replaceAllMapped(regex, (match) {
      final originalValue = double.parse(match.group(1)!);
      final adjustedValue = originalValue * _currentValue;
      return adjustedValue % 1 == 0 
          ? adjustedValue.toInt().toString()
          : adjustedValue.toStringAsFixed(1);
    });
  }
}