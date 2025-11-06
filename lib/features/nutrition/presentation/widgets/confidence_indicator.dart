import 'package:flutter/material.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final bool showLabel;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercentage = (confidence * 100).toInt();
    final color = _getConfidenceColor(confidence);
    final icon = _getConfidenceIcon(confidence);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSM,
        vertical: DesignTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: DesignTokens.spaceXS),
            Text(
              '$confidencePercentage%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return DesignTokens.success;
    } else if (confidence >= 0.6) {
      return DesignTokens.warning;
    } else {
      return DesignTokens.error;
    }
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) {
      return Icons.check_circle;
    } else if (confidence >= 0.6) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }
}