import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';

class CameraScanFood extends StatelessWidget {
  const CameraScanFood({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraProvider(
        camera: context.read<CameraDescription>(),
      )..initialize(),
      child: const _CameraScanFoodBody(),
    );
  }
}

class _CameraScanFoodBody extends StatelessWidget {
  const _CameraScanFoodBody();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();

    if (cameraProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // show preview if photo taken
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
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
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
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, CameraProvider cameraProvider) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตรวจสอบรูปภาพ')),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(cameraProvider.capturedImage!.path),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => cameraProvider.retake(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('ถ่ายใหม่'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final imagePath = cameraProvider.capturedImage!.path;
                      Navigator.pop(context, imagePath);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('ตกลง'),
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