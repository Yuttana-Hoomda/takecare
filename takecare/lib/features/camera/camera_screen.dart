import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'camera_provider.dart';

class CameraScreen extends StatelessWidget {
  final void Function(String imgBase64, String imageFilePath) onSubmit;
  final bool isLoading;

  const CameraScreen({super.key, required this.onSubmit, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
          CameraProvider(camera: context.read<CameraDescription>())
            ..initialize(),
        ),
      ],
      child: _CameraScreenBody(onSubmit, isLoading),
    );
  }
}

class _CameraScreenBody extends StatelessWidget {
  final void Function(String imgBase64, String imageFilePath) onSubmit;
  final bool isLoading;

  const _CameraScreenBody(this.onSubmit, this.isLoading);

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
      body: SafeArea(
        child: Stack(
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
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(70),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                ),
                icon: Icon(Icons.close_rounded, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, CameraProvider cameraProvider) {

    return Scaffold(
      body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(cameraProvider.capturedImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withAlpha(50),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'กำลังโหลด...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isLoading)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => cameraProvider.retake(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(70),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.refresh_rounded, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('ถ่ายใหม่', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () async {
                              final imageFilePath = cameraProvider.capturedImage!.path;
                              final bytes = await XFile(imageFilePath).readAsBytes();
                              final imgBase64 = base64Encode(bytes);

                              onSubmit(imgBase64, imageFilePath);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded),
                                const SizedBox(width: 6,),
                                Text('ส่งภาพ', style: TextStyle(color: Colors.white, fontSize: 18))
                              ],
                            )
                        ),
                      )
                    ],
                  ),
                ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black26
                    ),
                    child: Text('ตรวจสอบรูปภาพ', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
      )
    );
  }
}
