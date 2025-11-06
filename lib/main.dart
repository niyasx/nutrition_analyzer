import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutrition_app/app.dart';
import 'package:nutrition_app/core/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Setup dependency injection
  await di.init();
  
  runApp(const NutritionApp());
}