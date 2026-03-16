import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import '../models/automated_alarm_model.dart';
import '../providers/automated_alarm_provider.dart';
import '../widgets/alarm_action_button.dart';
import '../widgets/alarm_icon_widget.dart';
import '../widgets/alarm_info_widget.dart';

class AutomatedAlarmScreen extends StatelessWidget {
  final AutomatedAlarmModel alarm;

  const AutomatedAlarmScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AutomatedAlarmProvider(
        currentAlarm: alarm,
        elderlyId:    alarm.elderlyId,
        familyId:     alarm.familyId,
      ),
      child: const _AutomatedAlarmView(),
    );
  }
}

class _AutomatedAlarmView extends StatelessWidget {
  const _AutomatedAlarmView();

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<AutomatedAlarmProvider>();
    final state     = provider.actionState;
    final isBusy    = state == AlarmActionState.loading || state == AlarmActionState.submitting;
    final isCompleted = state == AlarmActionState.completed;

    if (state == AlarmActionState.error && provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red),
        );
        provider.clearError();
      });
    }

    if (isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEFFB), AppTheme.bgColorLight],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.capturedPhotoPath != null)
                        _PhotoPreview(path: provider.capturedPhotoPath!)
                      else ...[
                        const AlarmIconWidget(),
                        const SizedBox(height: 32),
                        AlarmInfoWidget(alarm: provider.currentAlarm),
                      ],
                      if (isBusy && provider.statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Text(provider.statusMessage,
                              style: const TextStyle(fontSize: 13, color: AppTheme.subtitle)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    children: [
                      AlarmActionButton(
                        label: isBusy ? provider.statusMessage : 'ทำเสร็จแล้ว (ถ่ายรูป)',
                        icon: Icons.camera_alt_rounded,
                        type: AlarmButtonType.primary,
                        isLoading: isBusy,
                        onPressed: isBusy ? null : provider.onDoneTakePhoto,
                      ),
                      const SizedBox(height: 12),
                      AlarmActionButton(
                        label: 'เลื่อน 15 นาที',
                        icon: Icons.access_alarm_rounded,
                        type: AlarmButtonType.secondary,
                        onPressed: isBusy ? null : () {
                          provider.onSnooze();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String path;
  const _PhotoPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(File(path), width: 200, height: 200, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
        const SizedBox(height: 4),
        const Text('บันทึกสำเร็จ กำลังกลับ...', style: TextStyle(fontSize: 13, color: Colors.green)),
      ],
    );
  }
}
