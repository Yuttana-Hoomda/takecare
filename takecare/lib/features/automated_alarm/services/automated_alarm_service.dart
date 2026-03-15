import 'package:image_picker/image_picker.dart';

class AutomatedAlarmService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return photo?.path;
  }
}
