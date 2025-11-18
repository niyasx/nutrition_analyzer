import 'dart:convert';
import 'package:nutrition_app/features/nutrition/data/models/food_item_model.dart';

class GeminiResponseModel {
  final List<GeminiCandidate> candidates;

  GeminiResponseModel({required this.candidates});

  factory GeminiResponseModel.fromJson(Map<String, dynamic> json) {
    return GeminiResponseModel(
      candidates: (json['candidates'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GeminiCandidate.fromJson)
          .toList(),
    );
  }

  List<FoodItemModel> get foodItems {
    if (candidates.isEmpty) return [];

    try {
      final textPart = candidates.first.content.parts
          .firstWhere((part) => part.text.trim().isNotEmpty, orElse: () => const GeminiPart(text: ''));
      if (textPart.text.trim().isEmpty) {
        return [];
      }
      final parsedJson = jsonDecode(textPart.text) as Map<String, dynamic>;
      final foodsJson = parsedJson['foods'] as List? ?? [];

      return foodsJson
          .whereType<Map<String, dynamic>>()
          .map(FoodItemModel.fromGeminiJson)
          .toList();
    } catch (e) {
      return [];
    }
  }
}

class GeminiCandidate {
  final GeminiContent content;

  GeminiCandidate({required this.content});

  factory GeminiCandidate.fromJson(Map<String, dynamic> json) {
    final contentJson = json['content'];
    if (contentJson is Map<String, dynamic>) {
      return GeminiCandidate(
        content: GeminiContent.fromJson(contentJson),
      );
    }
    return GeminiCandidate(
      content: const GeminiContent(parts: []),
    );
  }
}

class GeminiContent {
  final List<GeminiPart> parts;

  const GeminiContent({required this.parts});

  factory GeminiContent.fromJson(Map<String, dynamic> json) {
    return GeminiContent(
      parts: (json['parts'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GeminiPart.fromJson)
          .toList(),
    );
  }
}

class GeminiPart {
  final String text;

  const GeminiPart({required this.text});

  factory GeminiPart.fromJson(Map<String, dynamic> json) {
    return GeminiPart(
      text: json['text'] as String? ?? '',
    );
  }
}