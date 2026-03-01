import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:takecare/features/food_analysis/services/camera_service.dart';

class CameraProvider extends ChangeNotifier{
  final CameraService _cameraService;

  CameraProvider({required CameraDescription camera})
    : _cameraService = CameraService(camera: camera);

  bool _isLoading = true;
  bool _hasPermission = false;
  XFile? _capturedImage;
  String? _errMessage;

  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  XFile? get capturedImage => _capturedImage;
  String? get errMessage => _errMessage;
  CameraController? get cameraController => _cameraService.controller;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final status = await Permission.camera.request();
    _hasPermission = status.isGranted;

    if(_hasPermission) {
      try{
        await _cameraService.initCamera();
        _errMessage = null;
      } catch (err) {
        _errMessage = 'Failed to initialize camera: $err';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> takePicture() async {
    final file = await _cameraService.takePicture();
    if (file != null) {
      _capturedImage = file;
      notifyListeners();
    }
  }

  void retake() {
    _capturedImage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🔴 CameraProvider disposing...');
    _cameraService.dispose();
    super.dispose();
  }
}