import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/food_alarm/screens/food_analysis_screen.dart';
import '../providers/camera_provider.dart';
import '../providers/food_analysis_provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              CameraProvider(camera: context.read<CameraDescription>())
                ..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodAnalysisProvider(), // ✅ เพิ่มตรงนี้
        ),
      ],
      child: _CameraScreenBody(),
    );
  }
}

class _CameraScreenBody extends StatelessWidget {
  const _CameraScreenBody();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();

    if (cameraProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!cameraProvider.hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('ไม่ได้รับอนุญาตใช้กล้อง'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('เปิดการตั้งค่า'),
              ),
            ],
          ),
        ),
      );
    }

    if (cameraProvider.cameraController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cameraProvider.capturedImage != null) {
      return _buildPreview(context, cameraProvider);
    }

    return _buildCamera(context, cameraProvider);
  }

  Widget _buildCamera(BuildContext context, CameraProvider cameraProvider) {
    return Scaffold(
      appBar: AppBar(title: const Text('สแกนอาหาร')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(cameraProvider.cameraController!),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => cameraProvider.takePicture(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, CameraProvider cameraProvider) {
    final foodProvider = context.watch<FoodAnalysisProvider>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(cameraProvider.capturedImage!.path),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          if (foodProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'กำลังวิเคราะห์อาหาร...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if(!foodProvider.isLoading)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Retake button
                  GestureDetector(
                    onTap: () => cameraProvider.retake(),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                  GestureDetector(
                    onTap: () async {
                      final imageFilePath = cameraProvider.capturedImage!.path;
                      final bytes = await XFile(imageFilePath).readAsBytes();
                      final imgBase64 = base64Encode(bytes);

                      await context.read<FoodAnalysisProvider>().analysisFood(
                        imgBase64,
                        imageFilePath,
                        'hypertensiondwWWWWWWW'
                      );

                      if (!context.mounted) return;

                      final provider = context.read<FoodAnalysisProvider>();
                      debugPrint('result: ${provider.result}');
                      debugPrint('error: ${provider.error}');

                      if (provider.result != null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FoodAnalysisScreen(
                                  analysisResult: provider.result!,
                                  img: File(imageFilePath)
                              ),
                          ),
                            (route) => false
                        );
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withAlpha(85),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
