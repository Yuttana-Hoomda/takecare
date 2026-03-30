class DailySummary {
  final String date;
  final int totalCount;
  final int completedCount;
  final int missedCount;
  final int pendingCount;
  final double completedRate;

  const DailySummary({
    required this.date,
    required this.totalCount,
    required this.completedCount,
    required this.missedCount,
    required this.pendingCount,
    required this.completedRate,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date:           json['date'] as String? ?? '',
      totalCount:     json['totalCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      missedCount:    json['missedCount'] as int? ?? 0,
      pendingCount:   json['pendingCount'] as int? ?? 0,
      completedRate:  (json['completedRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // empty state before data loads
  factory DailySummary.empty() {
    return const DailySummary(
      date: '',
      totalCount: 0,
      completedCount: 0,
      missedCount: 0,
      pendingCount: 0,
      completedRate: 0.0,
    );
  }
}

class RecentEventItem {
  final String id;
  final String displayTitle;
  final String? displaySubtitle;
  final String status; // completed | missed | pending
  final String type;
  final String? thumbnailUrl;
  final String createdAt;

  const RecentEventItem({
    required this.id,
    required this.displayTitle,
    this.displaySubtitle,
    required this.status,
    required this.type,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory RecentEventItem.fromJson(Map<String, dynamic> json) {
    return RecentEventItem(
      id:              json['id'] as String? ?? '',
      displayTitle:    json['displayTitle'] as String? ?? '',
      displaySubtitle: json['displaySubtitle'] as String?,
      status:          json['status'] as String? ?? 'pending',
      type:            json['type'] as String? ?? 'task',
      thumbnailUrl:    json['thumbnailUrl'] as String?,
      createdAt:       json['createdAt'] as String? ?? '',
    );
  }
}

class ElderInfo {
  final String uid;
  final String displayName;
  final String phoneNumber;
  final String profileImgUrl;

  const ElderInfo({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.profileImgUrl,
  });

  factory ElderInfo.fromJson(Map<String, dynamic> json) {
    return ElderInfo(
      uid:           json['uid']           as String? ?? '',
      displayName:   json['displayName']   as String? ?? 'ผู้สูงอายุ',
      phoneNumber:   json['phoneNumber']   as String? ?? '',
      profileImgUrl: json['profileImgUrl'] as String? ?? '',
    );
  }

  factory ElderInfo.empty() => const ElderInfo(
    uid: '', displayName: '', phoneNumber: '', profileImgUrl: '',
  );
}
