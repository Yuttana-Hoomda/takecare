import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/models/user_model.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/history/models/event_model.dart';
import 'package:takecare/features/task_submission/providers/task_submission_provider.dart';
import 'package:takecare/constants/app_theme.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  Color _statusColor(BuildContext context) {
    if (event.isCompleted) return AppTheme.success;
    if (event.status == 'missed') return AppTheme.error;
    return Theme.of(context).colorScheme.primary;
  }

  String _statusLabel() {
    if (event.isCompleted) return 'เสร็จสิ้น';
    if (event.status == 'missed') return 'พลาด';
    return 'กำลังดำเนินการ';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final isFoodAnalysis = event.isFoodAnalysis;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFoodAnalysis ? 'วิเคราะห์อาหาร' : 'รายละเอียดกิจกรรม',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _HeroSection(event: event, statusColor: statusColor),
            const SizedBox(height: 20),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    event.isCompleted ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              event.displayTitle,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isFoodAnalysis
                    ? const Color(0xFFE8F8EE)
                    : const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFoodAnalysis ? Icons.restaurant : Icons.task_alt,
                    size: 16,
                    color: isFoodAnalysis
                        ? const Color(0xFF4DB887)
                        : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFoodAnalysis ? 'วิเคราะห์อาหาร' : 'กิจกรรม',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isFoodAnalysis
                          ? const Color(0xFF4DB887)
                          : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subtitle / ผลวิเคราะห์
            if (event.displaySubtitle != null && event.displaySubtitle!.isNotEmpty) ...[
              _InfoCard(
                title: isFoodAnalysis ? 'ผลวิเคราะห์' : 'รายละเอียด',
                content: event.displaySubtitle!,
                icon: isFoodAnalysis ? Icons.science_outlined : Icons.info_outline,
              ),
              const SizedBox(height: 16),
            ],

            // วันที่
            _InfoCard(
              title: 'วันที่',
              content: event.date,
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),

            // ประเภท collection
            _InfoCard(
              title: 'ประเภทข้อมูล',
              content: event.referenceCollection == 'food_analyses'
                  ? 'ผลวิเคราะห์อาหาร'
                  : 'บันทึกกิจกรรม',
              icon: Icons.folder_outlined,
            ),

            // ปุ่มทำเครื่องหมายว่าเสร็จสิ้น (เฉพาะ task ที่ยังไม่เสร็จ)
            if (!isFoodAnalysis && !event.isCompleted) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final user = context.read<AuthProvider>().user;
                    final token = context.read<AuthProvider>().firebaseToken ?? '';

                    if (user is! ElderUser) return;

                    if (user.familyId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ไม่พบข้อมูลครอบครัว กรุณาลองใหม่'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final success = await context
                        .read<TaskSubmissionProvider>()
                        .submit(
                      taskId: event.referenceId,
                      elderlyId: user.uid,
                      familyId: user.familyId!,
                      displayTitle: event.displayTitle,
                      token: token,
                      proofImgUrl: null,
                    );

                    if (!context.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('บันทึกเสร็จสิ้นแล้ว'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      final error = context
                          .read<TaskSubmissionProvider>()
                          .errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'ทำเครื่องหมายว่าเสร็จสิ้น',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Section
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  final Event event;
  final Color statusColor;

  const _HeroSection({required this.event, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    // foodAnalysis → แสดงรูป thumbnail
    if (event.isFoodAnalysis &&
        event.thumbnailUrl != null &&
        event.thumbnailUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          event.thumbnailUrl!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _IconHero(event: event, statusColor: statusColor),
        ),
      );
    }

    // task → แสดง icon ใหญ่
    return _IconHero(event: event, statusColor: statusColor);
  }
}

class _IconHero extends StatelessWidget {
  final Event event;
  final Color statusColor;

  const _IconHero({required this.event, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: SvgPicture.asset(
          event.icon,
          width: 80,
          height: 80,
          colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info Card
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}