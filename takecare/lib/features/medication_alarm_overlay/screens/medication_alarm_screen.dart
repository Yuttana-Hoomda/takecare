// lib/features/medication_alarm_overlay/screens/medication_alarm_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import '../providers/medication_alarm_provider.dart';
import '../widgets/alarm_action_button.dart';
import '../widgets/medication_icon_widget.dart';
import '../widgets/medication_info_widget.dart';

class MedicationAlarmScreen extends StatelessWidget {
  const MedicationAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicationAlarmProvider(),
      child: const _MedicationAlarmView(),
    );
  }
}

class _MedicationAlarmView extends StatelessWidget {
  const _MedicationAlarmView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicationAlarmProvider>();
    final isLoading = provider.actionState == AlarmActionState.loading;

    // แสดง error ถ้ามี
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.actionState == AlarmActionState.error &&
          provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

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
                      // Primary: Done + Take Photo
                      AlarmActionButton(
                        label: isLoading
                            ? 'Opening Camera...'
                            : 'Done (Take Photo)',
                        icon: Icons.camera_alt_rounded,
                        type: AlarmButtonType.primary,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : provider.onDoneTakePhoto,
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
