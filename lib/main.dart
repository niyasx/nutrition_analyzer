import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutrition_app/app.dart';
import 'package:nutrition_app/core/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (fallback if .env is missing)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Fallback to example env to avoid startup crash in dev
    try {
      await dotenv.load(fileName: ".env.example");
    } catch (_) {
      // If both fail, continue with empty env
    }
  }

  // Setup dependency injection
  await di.init();
  
  runApp(const NutritionApp());
}
