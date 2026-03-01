// lib/features/medication_alarm_overlay/screens/medication_alarm_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import '../models/medication_alarm_model.dart';
import '../providers/medication_alarm_provider.dart';
import '../widgets/alarm_action_button.dart';
import '../widgets/medication_icon_widget.dart';
import '../widgets/medication_info_widget.dart';

class MedicationAlarmScreen extends StatelessWidget {
  final MedicationAlarmModel alarm;
  final String? firebaseToken;

  const MedicationAlarmScreen({
    super.key,
    required this.alarm,
    this.firebaseToken,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicationAlarmProvider(
        currentAlarm: alarm,
        firebaseToken: firebaseToken,
      ),
      child: const _MedicationAlarmView(),
    );
  }
}

class _MedicationAlarmView extends StatelessWidget {
  const _MedicationAlarmView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicationAlarmProvider>();
    final state = provider.actionState;

    final isLoading = state == AlarmActionState.loading;
    final isUploading = state == AlarmActionState.uploading;
    final isCompleted = state == AlarmActionState.completed;
    final isBusy = isLoading || isUploading;

    if (state == AlarmActionState.error && provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        provider.clearError();
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
                      if (isCompleted && provider.capturedPhotoPath != null)
                        _PhotoPreview(
                          path: provider.capturedPhotoPath!,
                          url: provider.uploadedPhotoUrl,
                        )
                      else ...[
                        const MedicationIconWidget(),
                        const SizedBox(height: 32),
                        MedicationInfoWidget(alarm: provider.currentAlarm),
                      ],
                      if (isBusy && provider.statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _StatusIndicator(message: provider.statusMessage),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    children: [
                      if (!isCompleted) ...[
                        AlarmActionButton(
                          label: isBusy
                              ? provider.statusMessage
                              : 'Done (Take Photo)',
                          icon: Icons.camera_alt_rounded,
                          type: AlarmButtonType.primary,
                          isLoading: isBusy,
                          onPressed: isBusy ? null : provider.onDoneTakePhoto,
                        ),
                        const SizedBox(height: 12),
                        AlarmActionButton(
                          label: 'Snooze 15 mins',
                          icon: Icons.access_alarm_rounded,
                          type: AlarmButtonType.secondary,
                          onPressed: isBusy ? null : provider.onSnooze,
                        ),
                      ] else ...[
                        _DoneCard(url: provider.uploadedPhotoUrl),
                        const SizedBox(height: 12),
                        AlarmActionButton(
                          label: 'ปิด',
                          icon: Icons.check_circle_outline_rounded,
                          type: AlarmButtonType.secondary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
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
  final String? url;
  const _PhotoPreview({required this.path, this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            File(path),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        if (url != null) ...[
          const SizedBox(height: 12),
          Icon(Icons.cloud_done_rounded, color: Colors.green[600], size: 20),
          const SizedBox(height: 4),
          Text(
            'อัปโหลดสำเร็จ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String message;
  const _StatusIndicator({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(
          message,
          style: const TextStyle(fontSize: 13, color: AppTheme.subtitle),
        ),
      ],
    );
  }
}

class _DoneCard extends StatelessWidget {
  final String? url;
  const _DoneCard({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green[600]),
              const SizedBox(width: 8),
              Text(
                'บันทึกการกินยาสำเร็จ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          if (url != null) ...[
            const SizedBox(height: 8),
            Text(
              url!,
              style: TextStyle(fontSize: 11, color: Colors.green[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
