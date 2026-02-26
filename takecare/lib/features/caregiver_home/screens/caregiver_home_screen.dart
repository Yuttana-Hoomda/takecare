import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/caregiver_home/models/activity_item.dart';
import 'package:takecare/features/caregiver_home/widgets/caregiver_header.dart';
import 'package:takecare/features/caregiver_home/widgets/fast_call_card.dart';
import 'package:takecare/features/caregiver_home/widgets/progress_card.dart';
import 'package:takecare/features/caregiver_home/widgets/activity_list.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  static const List<ActivityItem> _activities = [
    ActivityItem(
      type: ActivityType.medication,
      title: 'Taken Blood Pressure Meds',
      subtitle: 'Confirmed by dispenser',
      time: '2:30 PM',
    ),
    ActivityItem(
      type: ActivityType.meal,
      title: 'Lunch Logged',
      subtitle: 'Grilled chicken salad',
      time: '12:15 PM',
    ),
    ActivityItem(
      type: ActivityType.walk,
      title: 'Morning Walk',
      subtitle: '850 steps recorded',
      time: '9:00 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          /// ── Sticky Header ──
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            toolbarHeight: 90,
            titleSpacing: 20,
            title: CaregiverHeader(
              name: 'Mom',
              avatarUrl:
                  'https://hilight.thaicdn.net/img_cms2/user/thachapol/tah/ee1226.jpg',
              isOnline: true,
            ),
          ),

          /// ── Body Content ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                FastCallCard(
                  title: 'โทรหาด่วน',
                  subtitle: 'บลาๆๆๆ',
                  onTap: () {},
                ),

                const SizedBox(height: 28),

                Text("Today's Progress", style: textTheme.titleMedium),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ProgressCard(
                        label: 'Medication',
                        valueText: '50%',
                        sublabel: '4/5 doses taken',
                        progress: 0.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ProgressCard(
                        label: 'Meals',
                        valueText: '2/3',
                        sublabel: 'Dinner pending',
                        progress: 2 / 3,
                        color: const Color(0xFFE07B00),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                ActivityList(items: _activities, onSeeAll: () {}),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
