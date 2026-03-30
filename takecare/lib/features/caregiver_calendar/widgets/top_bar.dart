import 'package:flutter/material.dart';
import 'package:takecare/features/caregiver_home/widgets/caregiver_header.dart';

//ดึงโค้ดที่เพื่อนทำไว้ เพื่อให้ appbar เหมือนกัน
class CaregiverTopBar extends StatelessWidget {
  const CaregiverTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return  CaregiverHeader(
        name: 'Mom',
        avatarUrl:
        'https://hilight.thaicdn.net/img_cms2/user/thachapol/tah/ee1226.jpg',
    );
  }
}
