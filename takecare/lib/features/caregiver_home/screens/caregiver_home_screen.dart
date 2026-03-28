import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/caregiver_home/models/daily_summary_model.dart';
import 'package:takecare/features/caregiver_home/providers/caregiver_home_provider.dart';
import 'package:takecare/features/caregiver_home/widgets/caregiver_header.dart';
import 'package:takecare/features/caregiver_home/widgets/fast_call_card.dart';
import 'package:takecare/features/caregiver_home/widgets/progress_card.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [FIX 4] ใช้ Provider จาก parent แทน ChangeNotifierProvider ใหม่
    // เพื่อไม่ให้ data หายทุกครั้งที่ rebuild
    // → ต้องลงทะเบียน CaregiverHomeProvider ไว้ใน MultiProvider ที่ main.dart หรือ main_wrapper.dart
    return const _CaregiverHomeView();
  }
}

class _CaregiverHomeView extends StatefulWidget {
  const _CaregiverHomeView();

  @override
  State<_CaregiverHomeView> createState() => _CaregiverHomeViewState();
}

class _CaregiverHomeViewState extends State<_CaregiverHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final familyId = context.read<AuthProvider>().user?.familyId;

    // [FIX 2] แจ้ง user เมื่อยังไม่ได้ link family แทนที่จะเงียบ
    if (familyId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเชื่อมต่อกับครอบครัวก่อนใช้งาน'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await context.read<CaregiverHomeProvider>().loadTodayData(familyId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaregiverHomeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final textTheme = Theme.of(context).textTheme;
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final familyId = user?.familyId;
          if (familyId != null) {
            await context.read<CaregiverHomeProvider>().loadTodayData(familyId);
          }
        },
        child: CustomScrollView(
          slivers: [
            // sticky header
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              toolbarHeight: 90,
              titleSpacing: 20,
              title: CaregiverHeader(
                name: user?.displayName ?? '',
                avatarUrl: user?.profilePictureUrl ?? '',
                isOnline: true,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  FastCallCard(
                    title: 'โทรหาด่วน',
                    subtitle: 'กดเพื่อโทรหาผู้สูงอายุ',
                    onTap: () {},
                  ),

                  const SizedBox(height: 28),

                  // [FIX 5] แสดง error message ถ้าโหลดไม่สำเร็จ
                  if (provider.errorMessage != null)
                    _ErrorBanner(
                      message: provider.errorMessage!,
                      onRetry: _load,
                    ),

                  Text("Today's Progress", style: textTheme.titleMedium),
                  const SizedBox(height: 14),

                  // progress cards
                  provider.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ProgressCard(
                                label: 'เสร็จสิ้น',
                                valueText: summary.totalCount > 0
                                    ? '${(summary.completedRate * 100).round()}%'
                                    : '-',
                                sublabel:
                                    '${summary.completedCount}/${summary.totalCount} รายการ',
                                progress: summary.completedRate,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ProgressCard(
                                label: 'ไม่ได้ทำ',
                                valueText: '${summary.missedCount}',
                                sublabel: 'รอดำเนินการ ${summary.pendingCount}',
                                progress: summary.totalCount > 0
                                    ? summary.missedCount / summary.totalCount
                                    : 0,
                                color: const Color(0xFFE44040),
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 28),

                  // recent activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Activity', style: textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (provider.isLoading)
                    const SizedBox.shrink()
                  else if (provider.recentEvents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'ยังไม่มีกิจกรรมวันนี้',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.subtitle,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.secondary),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.recentEvents.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 64,
                          endIndent: 16,
                          color: AppTheme.secondary,
                        ),
                        itemBuilder: (_, i) {
                          final event = provider.recentEvents[i];
                          return _EventTile(event: event);
                        },
                      ),
                    ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [FIX 5] Widget แสดง error พร้อมปุ่ม retry
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE44040).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE44040), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFE44040)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final RecentEventItem event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    IconData statusIcon;

    switch (event.status) {
      case 'completed':
        statusColor = const Color(0xFF2E7D32);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'missed':
        statusColor = const Color(0xFFE44040);
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = const Color(0xFFE07B00);
        statusIcon = Icons.pending_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.displayTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (event.displaySubtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.displaySubtitle!,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppTheme.subtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.status == 'completed'
                  ? 'เสร็จ'
                  : event.status == 'missed'
                  ? 'พลาด'
                  : 'รอ',
              style: textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
