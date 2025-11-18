import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/data/models/gemini_response_model.dart';

class GeminiApiClient {
  final Dio _dio;
  
  // TODO: Replace with actual Gemini API endpoint
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  GeminiApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // API key will be passed as query parameter in the request

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // Don't log image data
        responseBody: true,
        logPrint: (obj) => log(obj.toString(), name: 'GeminiAPI'),
      ),
    );
  }

  // Helper function to encode base64 in isolate to prevent main thread blocking
  static String _encodeBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  Future<GeminiResponseModel> analyzeImage(String imagePath) async {
    try {
      log('=== API CALL STARTED ===');
      log('Image path: $imagePath');
      print('=== API CALL STARTED ===');
      print('Image path: $imagePath');
      
      // Read image bytes asynchronously
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw ValidationException(
          message:
              'We could not locate the selected photo. Please choose another food photo and try again.',
        );
      }
      log('Reading image file...');
      List<int> imageBytes;
      try {
        imageBytes = await imageFile.readAsBytes();
      } on FileSystemException {
        throw ValidationException(
          message:
              'We had trouble reading that photo. Please take a new food photo and try again.',
        );
      }
      if (imageBytes.isEmpty) {
        throw ValidationException(
          message:
              'The selected photo appears to be empty. Please capture a clear photo of your meal and retry.',
        );
      }
      log('Image read: ${imageBytes.length} bytes');
      print('Image read: ${imageBytes.length} bytes');
      
      // Encode to base64 in isolate to prevent main thread blocking
      log('Encoding image to base64 in isolate...');
      print('Encoding image to base64 in isolate...');
      final base64Image = await compute(_encodeBase64, imageBytes);
      log('Base64 encoding completed: ${base64Image.length} characters');
      print('Base64 encoding completed: ${base64Image.length} characters');

      // Get API key from environment
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw ServerException(message: 'GEMINI_API_KEY not found in environment variables');
      }

      // Use correct Gemini API endpoint
      final response = await _dio.post(
        '/models/gemini-2.5-flash:generateContent?key=$apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '''
                    Analyze this food image and provide detailed nutritional information.
                    Return a JSON response with the following structure:
                    {
                      "foods": [
                        {
                          "name": "Food name",
                          "description": "Brief description",
                          "confidence": 0.95,
                          "nutrition": {
                            "calories": 250.0,
                            "protein": 12.0,
                            "carbs": 30.0,
                            "fat": 10.0,
                            "fiber": 5.0,
                            "sugar": 8.0,
                            "sodium": 300.0,
                            "micronutrients": {
                              "vitamin_c": 15.0,
                              "iron": 2.0,
                              "calcium": 100.0
                            },
                            "serving_size": "100g"
                          }
                        }
                      ]
                    }
                    Provide accurate nutritional data for all visible food items.
                  '''
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ]
        },
      );

      log('=== GEMINI API RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      print('=== GEMINI API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      
      // Log response summary instead of full data to avoid blocking
      if (response.data != null) {
        final responseStr = response.data.toString();
        final responsePreview = responseStr.length > 500 
            ? '${responseStr.substring(0, 500)}... (truncated)' 
            : responseStr;
        log('Response Preview: $responsePreview');
        print('Response Preview: $responsePreview');
      }
      print('===========================');

      if (response.statusCode != 200 || response.data == null) {
        throw ServerException(
          message:
              'Food analysis failed with status ${response.statusCode ?? 'unknown'}. Please try again shortly.',
        );
      }

      final model = GeminiResponseModel.fromJson(response.data);
      log('Parsed model - Food items: ${model.foodItems.length}');
      print('Parsed model - Food items: ${model.foodItems.length}');

      if (model.foodItems.isEmpty) {
        throw ValidationException(
          message:
              'We could not detect any food in that photo. Please take a clear picture of your meal and try again.',
        );
      }
      
      // Log food items summary
      for (var i = 0; i < model.foodItems.length; i++) {
        final item = model.foodItems[i];
        log('Food item $i: ${item.name} - Calories: ${item.nutritionData.calories}');
        print('Food item $i: ${item.name} - Calories: ${item.nutritionData.calories}');
      }
      
      return model;
    } on DioException catch (e) {
      log('Dio Error: ${e.message}');
      print('Dio Error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          message: 'The connection timed out. Please check your internet connection and try again.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          message: 'The server took too long to respond. Please try again in a moment.',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode;
        final message = e.response?.data?['error']?['message'] as String?;
        throw ServerException(
          message: message ??
              'Food analysis failed with status ${status ?? 'unknown'}. Please try again shortly.',
        );
      } else if (e.type == DioExceptionType.unknown &&
          e.error is SocketException) {
        throw NetworkException(
          message:
              'We could not reach the nutrition service. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw NetworkException(
          message: 'The request was cancelled before it finished.',
        );
      } else {
        throw ServerException(
          message: e.response?.data?['error']?['message'] ??
              e.message ??
              'An unexpected server error occurred.',
        );
      }
    } catch (e) {
      log('Unexpected error: $e');
      print('Unexpected error: $e');
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  // Mock response for development/testing
  Future<GeminiResponseModel> mockAnalyzeImage(String imagePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock data that matches expected structure
    final mockResponse = {
      "candidates": [
        {
          "content": {
            "parts": [
              {
                "text": jsonEncode({
                  "foods": [
                    {
                      "name": "Grilled Chicken Breast",
                      "description": "Lean protein source, appears grilled with herbs",
                      "confidence": 0.92,
                      "nutrition": {
                        "calories": 165.0,
                        "protein": 31.0,
                        "carbs": 0.0,
                        "fat": 3.6,
                        "fiber": 0.0,
                        "sugar": 0.0,
                        "sodium": 74.0,
                        "micronutrients": {
                          "vitamin_b6": 0.5,
                          "niacin": 8.5,
                          "phosphorus": 196.0,
                          "selenium": 22.0
                        },
                        "serving_size": "100g"
                      }
                    },
                    {
                      "name": "Steamed Broccoli",
                      "description": "Fresh green vegetables, lightly steamed",
                      "confidence": 0.89,
                      "nutrition": {
                        "calories": 34.0,
                        "protein": 2.8,
                        "carbs": 7.0,
                        "fat": 0.4,
                        "fiber": 2.6,
                        "sugar": 1.5,
                        "sodium": 33.0,
                        "micronutrients": {
                          "vitamin_c": 89.2,
                          "vitamin_k": 101.6,
                          "folate": 63.0,
                          "iron": 0.7
                        },
                        "serving_size": "100g"
                      }
                    }
                  ]
                })
              }
            ]
          }
        }
      ]
    };

    return GeminiResponseModel.fromJson(mockResponse);
  }
}

class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  ValidationException({required this.message});
}