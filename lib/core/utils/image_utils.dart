import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:nutrition_app/core/constants/app_contants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// Fixed import to use existing constants file name

class ImageUtils {
  /// Compress image to reduce file size
  static Future<File> compressImage(File imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize if image is too large
      if (image.width > AppConstants.maxImageWidth || 
          image.height > AppConstants.maxImageHeight) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? AppConstants.maxImageWidth : null,
          height: image.height > image.width ? AppConstants.maxImageHeight : null,
        );
      }
      
      // Compress image
      final compressedBytes = img.encodeJpg(
        image,
        quality: AppConstants.imageQuality,
      );
      
      // Save compressed image
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageFile; // Return original if compression fails
    }
  }
  
  /// Validate image file
  static Future<bool> validateImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return false;
      }
      
      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > AppConstants.maxFileSize) {
        throw Exception('Image size exceeds maximum allowed size');
      }
      
      // Check file extension
      final extension = path.extension(imageFile.path).toLowerCase();
      final allowedExtensions = AppConstants.allowedImageExtensions
          .map((ext) => '.$ext')
          .toList();
      
      if (!allowedExtensions.contains(extension)) {
        throw Exception('Invalid image format');
      }
      
      // Try to decode image to verify it's a valid image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      return image != null;
    } catch (e) {
      debugPrint('Image validation error: $e');
      return false;
    }
  }
  
  /// Get image dimensions
  static Future<Size?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        return Size(image.width.toDouble(), image.height.toDouble());
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return null;
    }
  }
  
  /// Convert File to Uint8List
  static Future<Uint8List> fileToUint8List(File file) async {
    return await file.readAsBytes();
  }
  
  /// Save image to permanent storage
  static Future<String> saveImagePermanently(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final savedImagesDir = Directory('${appDir.path}/nutrition_images');
      
      // Create directory if it doesn't exist
      if (!await savedImagesDir.exists()) {
        await savedImagesDir.create(recursive: true);
      }
      
      // Generate unique filename
      final fileName = 'nutrition_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(savedImagesDir.path, fileName);
      
      // Copy file
      await imageFile.copy(savedPath);
      
      return savedPath;
    } catch (e) {
      debugPrint('Error saving image permanently: $e');
      rethrow;
    }
  }
  
  /// Delete saved image
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
  
  /// Clean up old temporary images
  static Future<void> cleanupTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && 
            path.basename(file.path).startsWith('compressed_')) {
          try {
            await file.delete();
          } catch (e) {
            debugPrint('Error deleting temp file: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp images: $e');
    }
  }
  
  /// Rotate image
  static Future<File> rotateImage(File imageFile, int degrees) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Rotate image
      final rotated = img.copyRotate(image, angle: degrees);
      
      // Save rotated image
      final rotatedBytes = img.encodeJpg(rotated);
      await imageFile.writeAsBytes(rotatedBytes);
      
      return imageFile;
    } catch (e) {
      debugPrint('Error rotating image: $e');
      return imageFile;
    }
  }
  
  /// Crop image to square
  static Future<File> cropToSquare(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Determine crop size (smaller dimension)
      final cropSize = image.width < image.height ? image.width : image.height;
      
      // Calculate crop position (center)
      final x = (image.width - cropSize) ~/ 2;
      final y = (image.height - cropSize) ~/ 2;
      
      // Crop image
      final cropped = img.copyCrop(
        image,
        x: x,
        y: y,
        width: cropSize,
        height: cropSize,
      );
      
      // Save cropped image
      final croppedBytes = img.encodeJpg(cropped);
      await imageFile.writeAsBytes(croppedBytes);
      
      return imageFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return imageFile;
    }
  }
  
  /// Get image file size in MB
  static Future<double> getImageSizeMB(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0.0;
    }
  }
  
  /// Check if image needs compression
  static Future<bool> needsCompression(File imageFile) async {
    try {
      final sizeMB = await getImageSizeMB(imageFile);
      final dimensions = await getImageDimensions(imageFile);
      
      return sizeMB > 2.0 || 
             (dimensions != null && 
              (dimensions.width > AppConstants.maxImageWidth || 
               dimensions.height > AppConstants.maxImageHeight));
    } catch (e) {
      debugPrint('Error checking compression need: $e');
      return false;
    }
  }
}