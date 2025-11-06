import 'dart:convert';
import 'package:nutrition_app/features/nutrition/data/models/food_item_model.dart';

class GeminiResponseModel {
  final List<GeminiCandidate> candidates;

  GeminiResponseModel({required this.candidates});

  factory GeminiResponseModel.fromJson(Map<String, dynamic> json) {
    return GeminiResponseModel(
      candidates: (json['candidates'] as List? ?? [])
          .map((e) => GeminiCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<FoodItemModel> get foodItems {
    if (candidates.isEmpty) return [];
    
    try {
      final textContent = candidates.first.content.parts.first.text;
      final parsedJson = jsonDecode(textContent) as Map<String, dynamic>;
      final foodsJson = parsedJson['foods'] as List? ?? [];
      
      return foodsJson
          .map((foodJson) => FoodItemModel.fromGeminiJson(foodJson as Map<String, dynamic>))
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
    return GeminiCandidate(
      content: GeminiContent.fromJson(json['content'] as Map<String, dynamic>),
    );
  }
}

class GeminiContent {
  final List<GeminiPart> parts;

  GeminiContent({required this.parts});

  factory GeminiContent.fromJson(Map<String, dynamic> json) {
    return GeminiContent(
      parts: (json['parts'] as List? ?? [])
          .map((e) => GeminiPart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeminiPart {
  final String text;

  GeminiPart({required this.text});

  factory GeminiPart.fromJson(Map<String, dynamic> json) {
    return GeminiPart(
      text: json['text'] as String? ?? '',
    );
  }
}