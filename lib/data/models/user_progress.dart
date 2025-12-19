class UserProgress {
  final int totalXp;
  final List<String> completedLessonIds;
  final int currentStreak;
  final DateTime? lastActivityDate;

  const UserProgress({
    required this.totalXp,
    required this.completedLessonIds,
    required this.currentStreak,
    required this.lastActivityDate,
  });

  factory UserProgress.initial() {
    return const UserProgress(
      totalXp: 0,
      completedLessonIds: <String>[],
      currentStreak: 0,
      lastActivityDate: null,
    );
  }

  UserProgress copyWith({
    int? totalXp,
    List<String>? completedLessonIds,
    int? currentStreak,
    DateTime? lastActivityDate,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'completedLessonIds': completedLessonIds,
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXp: json['totalXp'] as int? ?? 0,
      completedLessonIds:
          (json['completedLessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          <String>[],
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
    );
  }
}
