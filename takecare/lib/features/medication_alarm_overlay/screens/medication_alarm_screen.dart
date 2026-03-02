// lib/features/medication_alarm_overlay/screens/task_alarm_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/medication_alarm_overlay/screens/camera_screen.dart';
import '../models/medication_alarm_model.dart';
import '../providers/medication_alarm_provider.dart';
import '../widgets/alarm_action_button.dart';
import '../widgets/medication_icon_widget.dart';
import '../widgets/medication_info_widget.dart';

class TaskAlarmScreen extends StatelessWidget {
  final MedicationAlarmModel alarm; //   รับ alarm จากภายนอก

  const TaskAlarmScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskAlarmProvider(currentAlarm: alarm),
      child: const _TaskAlarmView(),
    );
  }
}

class _TaskAlarmView extends StatelessWidget {
  const _TaskAlarmView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskAlarmProvider>();
    final isLoading = provider.actionState == AlarmActionState.loading;

    //   แสดง snackbar เฉพาะครั้งแรกที่เข้าสู่ state error แล้ว clearError ทันที
    if (provider.actionState == AlarmActionState.error &&
        provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        provider.clearError(); // reset หลังแสดงแล้ว ไม่ยิงซ้ำ
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
                // ─── Top Content ───────────────────────────
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MedicationIconWidget(),
                      const SizedBox(height: 32),
                      MedicationInfoWidget(alarm: provider.currentAlarm),
                    ],
                  ),
                ),

                // ─── Action Buttons ────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    children: [
                      AlarmActionButton(
                        label: isLoading
                            ? 'Opening Camera...'
                            : 'Done (Take Photo)',
                        icon: Icons.camera_alt_rounded,
                        type: AlarmButtonType.primary,
                        isLoading: isLoading,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CameraScreen())
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Secondary: Snooze
                      AlarmActionButton(
                        label: 'Snooze 15 mins',
                        icon: Icons.access_alarm_rounded,
                        type: AlarmButtonType.secondary,
                        onPressed: isLoading ? null : provider.onSnooze,
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
