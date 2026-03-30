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
      // ✅ [NEW] แยก view ตาม requirePhoto
      child: alarm.requirePhoto
          ? const _PhotoAlarmView()
          : const _NormalAlarmView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PHOTO ALARM VIEW — สำหรับ task ที่ requirePhoto = true (เหมือนเดิม)
// ─────────────────────────────────────────────────────────────────

class _PhotoAlarmView extends StatelessWidget {
  const _PhotoAlarmView();

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<AutomatedAlarmProvider>();
    final state       = provider.actionState;
    final isBusy      = state == AlarmActionState.loading ||
                        state == AlarmActionState.submitting;
    final isCompleted = state == AlarmActionState.completed;

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
                            Text(
                              provider.statusMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.subtitle,
                              ),
                            ),
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
                        label: isBusy
                            ? provider.statusMessage
                            : 'ทำเสร็จแล้ว (ถ่ายรูป)',
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
                        onPressed: isBusy
                            ? null
                            : () {
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

// ─────────────────────────────────────────────────────────────────
// NORMAL ALARM VIEW — task ทั่วไป requirePhoto = false (ใหม่)
// ─────────────────────────────────────────────────────────────────

class _NormalAlarmView extends StatelessWidget {
  const _NormalAlarmView();

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<AutomatedAlarmProvider>();
    final alarm       = provider.currentAlarm;
    final state       = provider.actionState;
    final isBusy      = state == AlarmActionState.submitting;
    final isCompleted = state == AlarmActionState.completed;
    final textTheme   = Theme.of(context).textTheme;

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

    if (isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_alarm_rounded,
                            size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'ถึงเวลาแล้ว',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // ปุ่ม X ปิด
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F4F8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Task Icon ─────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Task Title ────────────────────────
              Center(
                child: Text(
                  alarm.title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: const Color(0xFF0A1628),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Scheduled Time ────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 15, color: AppTheme.subtitle),
                    const SizedBox(width: 4),
                    Text(
                      alarm.scheduledTime,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.subtitle,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Note (ถ้ามี) ───────────────────────
              if (alarm.notes != null && alarm.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'หมายเหตุ',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.subtitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alarm.notes!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF1A202C),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // ── Loading indicator ─────────────────
              if (isBusy) ...[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        provider.statusMessage,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppTheme.subtitle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Action Buttons ─────────────────────
              AlarmActionButton(
                label: isBusy ? provider.statusMessage : 'เสร็จสิ้น',
                icon: Icons.check_circle_rounded,
                type: AlarmButtonType.primary,
                isLoading: isBusy,
                onPressed: isBusy ? null : provider.onDoneWithoutPhoto,
              ),
              const SizedBox(height: 12),
              AlarmActionButton(
                label: 'เลื่อน 15 นาที',
                icon: Icons.access_alarm_rounded,
                type: AlarmButtonType.secondary,
                onPressed: isBusy
                    ? null
                    : () {
                        provider.onSnooze();
                        Navigator.of(context).pop();
                      },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Photo Preview widget (ใช้ร่วมกัน)
// ─────────────────────────────────────────────────────────────────

class _PhotoPreview extends StatelessWidget {
  final String path;
  const _PhotoPreview({required this.path});

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
        const SizedBox(height: 12),
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
        const SizedBox(height: 4),
        const Text(
          'บันทึกสำเร็จ กำลังกลับ...',
          style: TextStyle(fontSize: 13, color: Colors.green),
        ),
      ],
    );
  }
}
