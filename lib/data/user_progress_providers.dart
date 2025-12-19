import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_duolingo/data/models/user_progress.dart';
import 'package:mini_duolingo/data/repositories/user_progress_repository.dart';

final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  return UserProgressRepository();
});

final userProgressProvider =
    AsyncNotifierProvider<UserProgressNotifier, UserProgress>(
      UserProgressNotifier.new,
    );

class UserProgressNotifier extends AsyncNotifier<UserProgress> {
  UserProgressRepository get _repository =>
      ref.read(userProgressRepositoryProvider);

  @override
  Future<UserProgress> build() async {
    final progress = await _repository.load();
    return progress;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int _nextStreak({
    required DateTime? lastDate,
    required DateTime todayDate,
    required int currentStreak,
  }) {
    if (lastDate == null) return 1;

    final diff = todayDate.difference(lastDate).inDays;
    if (diff == 0) return currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  Future<UserProgress> _current() async {
    return state.value ?? await future;
  }

  Future<void> _setAndSave(UserProgress next) async {
    final previousState = state;

    state = AsyncData(next);

    try {
      await _repository.save(next);
    } catch (e, st) {
      state = previousState;
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;

    final current = await _current();
    final updated = current.copyWith(totalXp: current.totalXp + amount);
    await _setAndSave(updated);
  }

  Future<void> markLessonCompleted(String lessonId) async {
    final current = await _current();

    if (current.completedLessonIds.contains(lessonId)) {
      return;
    }

    final updated = current.copyWith(
      completedLessonIds: [...current.completedLessonIds, lessonId],
    );
    await _setAndSave(updated);
  }

  Future<void> updateStreakOnStudyToday() async {
    final current = await _current();

    final todayDate = _dateOnly(DateTime.now());
    final lastDate = current.lastActivityDate == null
        ? null
        : _dateOnly(current.lastActivityDate!);

    final newStreak = _nextStreak(
      lastDate: lastDate,
      todayDate: todayDate,
      currentStreak: current.currentStreak,
    );

    final updated = current.copyWith(
      currentStreak: newStreak,
      lastActivityDate: lastDate,
    );

    await _setAndSave(updated);
  }

  Future<void> applyLessonCompletion({
    required String lessonId,
    required int correctAnswers,
  }) async {
    final current = await _current();

    final xpGain = (correctAnswers <= 0) ? 0 : correctAnswers * 10;

    final todayDate = _dateOnly(DateTime.now());
    final lastDate = current.lastActivityDate == null
        ? null
        : _dateOnly(current.lastActivityDate!);

    final newStreak = _nextStreak(
      lastDate: lastDate,
      todayDate: todayDate,
      currentStreak: current.currentStreak,
    );

    final completed = current.completedLessonIds.contains(lessonId)
        ? current.completedLessonIds
        : [...current.completedLessonIds, lessonId];

    final updated = current.copyWith(
      totalXp: current.totalXp + xpGain,
      completedLessonIds: completed,
      currentStreak: newStreak,
      lastActivityDate: todayDate,
    );

    await _setAndSave(updated);
  }

  Future<void> resetProgress() async {
    await _setAndSave(UserProgress.initial());
  }
}
