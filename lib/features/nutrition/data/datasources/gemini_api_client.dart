import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
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

    // Add API key from environment
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null) {
      _dio.options.headers['Authorization'] = 'Bearer $apiKey';
    }

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // Don't log image data
        responseBody: true,
        logPrint: (obj) => log(obj.toString(), name: 'GeminiAPI'),
      ),
    );
  }

  Future<GeminiResponseModel> analyzeImage(String imagePath) async {
    try {
      // Convert image to base64
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // TODO: Replace with actual Gemini API endpoint structure
      final response = await _dio.post(
        '/models/gemini-pro-vision:generateContent', // Placeholder endpoint
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

      log('Gemini API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return GeminiResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'API request failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('Dio Error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Receive timeout');
      } else {
        throw ServerException(
          message: e.response?.data?['error']?['message'] ?? e.message ?? 'Unknown error',
        );
      }
    } catch (e) {
      log('Unexpected error: $e');
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