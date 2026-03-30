import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/camera/camera_screen.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/task_submission/providers/task_submission_provider.dart';
import '../../auth/models/user_model.dart';

class TaskAlarmScreen extends StatelessWidget {
  final String taskId;
  final IconData icon;
  final String time;
  final String title;
  final String description;
  final bool isRequiredCamera;
  final Color color;

  const TaskAlarmScreen({
    super.key,
    required this.taskId,
    required this.icon,
    required this.time,
    required this.title,
    required this.description,
    required this.color,
    this.isRequiredCamera = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.12),
                      ),
                      child: Icon(icon, size: 56, color: color),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme.bodyLarge
                            ?.copyWith(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => isRequiredCamera
                          ? _onTapCamera(context)
                          : _onDone(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRequiredCamera
                                ? Icons.photo_camera_rounded
                                : Icons.check_circle_rounded,
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isRequiredCamera ? 'กินแล้ว (ถ่ายรูป)' : 'ทำแล้ว',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.access_alarm_rounded, size: 25),
                          SizedBox(width: 10),
                          Text('เลื่อนออกไป 15 นาที'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ CAMERA FLOW
  Future<void> _onTapCamera(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          isLoading: false,
          onSubmit: (imgBase64, imageFilePath) async {
            final user = context.read<AuthProvider>().user;
            final token = context.read<AuthProvider>().firebaseToken ?? '';

            if (user is! ElderUser) return;

            final success = await _submitTask(
              context: context,
              user: user,
              token: token,
              proofImgUrl: imgBase64,
            );

            if (!success || !context.mounted) return;

            Navigator.pop(context, true);
          },
        ),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  // ✅ NORMAL FLOW
  Future<void> _onDone(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    final token = context.read<AuthProvider>().firebaseToken ?? '';

    if (user is! ElderUser) return;

    final success = await _submitTask(
      context: context,
      user: user,
      token: token,
      proofImgUrl: null,
    );

    if (success && context.mounted) {
      Navigator.pop(context, true); // 🔥 สำคัญที่สุด
    }
  }

  // ✅ SUBMIT
  Future<bool> _submitTask({

    required BuildContext context,
    required ElderUser user,
    required String token,
    String? proofImgUrl,
  }) async {
    if (user.familyId == null) return false;

    final success = await context.read<TaskSubmissionProvider>().submit(
      taskId: taskId,
      elderlyId: user.uid,
      familyId: user.familyId!,
      displayTitle: title,
      token: token,
      proofImgUrl: proofImgUrl,
    );
    return success;
  }
}