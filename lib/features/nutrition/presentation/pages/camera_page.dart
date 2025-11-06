import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';
import 'package:nutrition_app/core/utils/image_utils.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_bloc.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/nutrition_analysis_event.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  FlashMode _flashMode = FlashMode.auto;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          _showError('No cameras available on this device');
        }
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        _showError('Failed to initialize camera: $e');
      }
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);

      // Validate image
      final isValid = await ImageUtils.validateImage(imageFile);
      if (!isValid) {
        _showError('Invalid image. Please try again.');
        return;
      }

      // Compress image if needed
      File processedImage = imageFile;
      if (await ImageUtils.needsCompression(imageFile)) {
        processedImage = await ImageUtils.compressImage(imageFile);
      }

      if (mounted) {
        // Navigate to preview or directly analyze
        _analyzeImage(processedImage.path);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      _showError('Failed to capture image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final File imageFile = File(image.path);
        
        // Validate image
        final isValid = await ImageUtils.validateImage(imageFile);
        if (!isValid) {
          _showError('Invalid image. Please select a different image.');
          return;
        }

        // Compress image if needed
        File processedImage = imageFile;
        if (await ImageUtils.needsCompression(imageFile)) {
          processedImage = await ImageUtils.compressImage(imageFile);
        }

        _analyzeImage(processedImage.path);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      _showError('Failed to select image: $e');
    }
  }

  void _analyzeImage(String imagePath) {
    context.read<NutritionAnalysisBloc>().add(
          AnalyzeImage(imagePath: imagePath),
        );
    context.go('/results');
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto;
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.always;
      } else {
        _flashMode = FlashMode.off;
      }
    });

    await _cameraController!.setFlashMode(_flashMode);
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isInitialized = false;
    });

    final currentCamera = _cameraController!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera != currentCamera,
      orElse: () => _cameras![0],
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error switching camera: $e');
      _showError('Failed to switch camera: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: DesignTokens.primaryGreen,
              ),
            ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    iconSize: 30,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),

                  // Flash Button
                  if (_isInitialized)
                    IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(_getFlashIcon()),
                      color: Colors.white,
                      iconSize: 30,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceLG,
                horizontal: DesignTokens.spaceMD,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    IconButton(
                      onPressed: _isProcessing ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      color: Colors.white,
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                      ),
                    ),

                    // Capture Button
                    GestureDetector(
                      onTap: _isProcessing ? null : _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isProcessing
                                  ? Colors.grey
                                  : DesignTokens.primaryGreen,
                            ),
                            child: _isProcessing
                                ? const Padding(
                                    padding: EdgeInsets.all(DesignTokens.spaceMD),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // Switch Camera Button
                    if (_cameras != null && _cameras!.length > 1)
                      IconButton(
                        onPressed: _isProcessing ? null : _switchCamera,
                        icon: const Icon(Icons.flip_camera_ios),
                        color: Colors.white,
                        iconSize: 32,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                          padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        ),
                      )
                    else
                      const SizedBox(width: 64), // Spacer for alignment
                  ],
                ),
              ),
            ),
          ),

          // Hint Text
          if (_isInitialized)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMD,
                    vertical: DesignTokens.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  ),
                  child: const Text(
                    'Position food in the center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}