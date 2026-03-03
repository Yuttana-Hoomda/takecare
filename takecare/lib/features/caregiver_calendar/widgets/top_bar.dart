import 'package:flutter/material.dart';
import 'package:takecare/features/caregiver_home/widgets/caregiver_header.dart';

class CaregiverTopBar extends StatelessWidget {
  const CaregiverTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return  CaregiverHeader(
        name: 'Mom',
        avatarUrl:
        'https://hilight.thaicdn.net/img_cms2/user/thachapol/tah/ee1226.jpg',
        isOnline: true,
    );
  }
}
