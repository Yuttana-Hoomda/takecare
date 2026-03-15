// lib/features/medication_alarm_overlay/services/medication_alarm_service.dart

import 'package:image_picker/image_picker.dart';

class MedicationAlarmService {
  final ImagePicker _picker = ImagePicker();

  /// เปิดกล้องถ่ายรูป แล้วคืน path ของรูปที่ถ่าย
  /// คืน null ถ้าผู้ใช้ยกเลิก
  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return photo?.path;
  }
}
