import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExerciseRunStatus { answering, feedback, completed }

class ExerciseState {
  final int currentIndex;
  final int correctCount;
  final int wrongCount;
  final ExerciseRunStatus status;
  final bool? lastAnswerCorrect;

  const ExerciseState({
    required this.currentIndex,
    required this.correctCount,
    required this.wrongCount,
    required this.status,
    required this.lastAnswerCorrect,
  });

  factory ExerciseState.initial() {
    return const ExerciseState(
      currentIndex: 0,
      correctCount: 0,
      wrongCount: 0,
      status: ExerciseRunStatus.answering,
      lastAnswerCorrect: null,
    );
  }

  ExerciseState copyWith({
    int? currentIndex,
    int? correctCount,
    int? wrongCount,
    ExerciseRunStatus? status,
    bool? lastAnswerCorrect,
  }) {
    return ExerciseState(
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      status: status ?? this.status,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
    );
  }
}

class ExerciseController extends Notifier<ExerciseState> {
  @override
  ExerciseState build() {
    return ExerciseState.initial();
  }

  void submitAnswer({required bool isCorrect}) {
    if (state.status != ExerciseRunStatus.answering) return;

    state = state.copyWith(
      status: ExerciseRunStatus.feedback,
      lastAnswerCorrect: isCorrect,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      wrongCount: state.wrongCount + (isCorrect ? 0 : 1),
    );
  }

  void goToNext({required int totalQuestions}) {
    if (state.status == ExerciseRunStatus.completed) return;

    final isLastQuestion = state.currentIndex >= totalQuestions - 1;

    if (isLastQuestion) {
      state = state.copyWith(status: ExerciseRunStatus.completed);
    } else {
      state = ExerciseState(
        currentIndex: state.currentIndex + 1,
        correctCount: state.correctCount,
        wrongCount: state.wrongCount,
        status: ExerciseRunStatus.answering,
        lastAnswerCorrect: null,
      );
    }
  }

  void restartLesson() {
    state = ExerciseState.initial();
  }
}

final exerciseControllerProvider =
    NotifierProvider.autoDispose<ExerciseController, ExerciseState>(
      ExerciseController.new,
    );
