import 'package:camera/camera.dart';

class CameraService {
  final CameraDescription camera;
  CameraController? _controller;

  CameraService({required this.camera});

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initCamera() async {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium
    );
    await _controller!.initialize();
  }

  Future<XFile?> takePicture() async {
    if(!isInitialized) return null;
    return await _controller!.takePicture();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}