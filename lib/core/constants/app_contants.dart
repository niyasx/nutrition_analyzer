class AppConstants {
  // App Information
  static const String appName = 'Nutrition Analyzer';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered nutrition analysis for your meals';
  
  // API Configuration
  static const String geminiApiVersion = 'v1beta';
  static const String geminiModel = 'gemini-pro-vision';
  
  // Storage Keys
  static const String analysisBoxName = 'analysis_results';
  static const String userPreferencesBoxName = 'user_preferences';
  
  // Image Configuration
  static const int imageQuality = 85;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const double imageCompressionQuality = 0.8;
  
  // Nutrition Thresholds
  static const double minConfidenceScore = 0.5;
  static const double highConfidenceScore = 0.8;
  static const double minPortionMultiplier = 0.1;
  static const double maxPortionMultiplier = 5.0;
  
  // UI Configuration
  static const int maxHistoryItems = 100;
  static const int recentAnalysisCount = 5;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Error Messages
  static const String networkErrorMessage = 'No internet connection. Please check your network and try again.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String imagePickerErrorMessage = 'Failed to select image. Please try again.';
  static const String analysisErrorMessage = 'Failed to analyze image. Please try again.';
  static const String storageErrorMessage = 'Failed to save data. Please check storage permissions.';
  
  // Success Messages
  static const String analysisSavedMessage = 'Analysis saved successfully!';
  static const String analysisDeletedMessage = 'Analysis deleted successfully!';
  
  // Validation
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'heic'];
  
  // Analytics Events (for future integration)
  static const String eventImageCaptured = 'image_captured';
  static const String eventImageAnalyzed = 'image_analyzed';
  static const String eventAnalysisSaved = 'analysis_saved';
  static const String eventPortionAdjusted = 'portion_adjusted';
  
  // Feature Flags
  static const bool enableMockApi = true; // Set to false for production
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  
  // Nutritional Reference Values (Daily Recommended Intake)
  static const double dailyCalories = 2000;
  static const double dailyProtein = 50;
  static const double dailyCarbs = 300;
  static const double dailyFat = 70;
  static const double dailyFiber = 25;
  static const double dailySugar = 50;
  static const double dailySodium = 2300;
  
  // Micronutrients Daily Values
  static const Map<String, double> dailyMicronutrients = {
    'vitamin_a': 900,
    'vitamin_c': 90,
    'vitamin_d': 20,
    'vitamin_e': 15,
    'vitamin_k': 120,
    'calcium': 1000,
    'iron': 18,
    'magnesium': 400,
    'phosphorus': 700,
    'potassium': 3500,
    'zinc': 11,
  };
  
  // Prompt for Gemini API
  static const String nutritionAnalysisPrompt = '''
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
If multiple items are detected, include them all in the foods array.
''';
}