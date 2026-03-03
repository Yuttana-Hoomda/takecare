import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/setting_button.dart';
import '/features/auth/providers/auth_provider.dart';

Widget buildHeader(BuildContext context) {
  final user = Provider.of<AuthProvider>(context, listen: false).user;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CircleAvatar(
        radius: 25,
        backgroundImage: user?.profilePictureUrl.isNotEmpty == true ? NetworkImage(user!.profilePictureUrl) : null,
        child: user?.profilePictureUrl.isEmpty == true ? const Icon(Icons.person, color: Colors.white) : null,
      ),
      const SettingButton(),
    ],
  );
}