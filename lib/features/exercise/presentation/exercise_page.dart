import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/core/routing/app_router.dart';
import 'package:mini_duolingo/data/lesson_providers.dart';
import 'package:mini_duolingo/data/user_progress_providers.dart';
import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/features/exercise/application/exercise_controller.dart';
import 'package:mini_duolingo/features/exercise/presentation/widgets/translation_exercise_view.dart';
import 'package:mini_duolingo/features/exercise/presentation/widgets/word_tiles_exercise_view.dart';
import 'package:mini_duolingo/features/exercise/presentation/widgets/picture_selection_exercise_view.dart';

class ExercisePage extends ConsumerWidget {
  final String lessonId;

  const ExercisePage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExerciseState>(exerciseControllerProvider, (previous, next) {
      final wasCompleted = previous?.status == ExerciseRunStatus.completed;
      final isCompleted = next.status == ExerciseRunStatus.completed;

      if (!wasCompleted && isCompleted) {
        final correctAnswers = next.correctCount;
        ref
            .read(userProgressProvider.notifier)
            .applyLessonCompletion(
              lessonId: lessonId,
              correctAnswers: correctAnswers,
            );
      }
    });

    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));
    final exerciseState = ref.watch(exerciseControllerProvider);
    final exerciseController = ref.read(exerciseControllerProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        if (exerciseState.status == ExerciseRunStatus.completed) {
          return true;
        }

        final shouldLeave =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Keluar dari lesson?'),
                content: const Text(
                  'Progress lesson ini akan hilang dan'
                  'kamu harus mengulang dari awal',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Tetap Kerjakan'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ) ??
            false;

        return shouldLeave;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Lesson: $lessonId')),
        body: lessonAsync.when(
          data: (lesson) {
            if (lesson == null) {
              return const Center(child: Text('Lesson tidak ditemukan'));
            }

            if (lesson.exercises.isEmpty) {
              return const Center(child: Text('Lesson ini belum punya soal.'));
            }

            final totalQuestions = lesson.exercises.length;
            if (exerciseState.status == ExerciseRunStatus.completed) {
              return _buildSummaryView(
                context: context,
                state: exerciseState,
                totalQuestions: totalQuestions,
                onRestart: exerciseController.restartLesson,
              );
            }

            final currentIndex = exerciseState.currentIndex.clamp(
              0,
              totalQuestions - 1,
            );
            final currentExercise = lesson.exercises[currentIndex];

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soal ${currentIndex + 1} dari $totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / totalQuestions,
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildExerciseContent(
                        currentExercise,
                        exerciseState,
                        (isCorrect) {
                          exerciseController.submitAnswer(isCorrect: isCorrect);
                        },
                      ),
                    ),
                  ),

                  if (exerciseState.status == ExerciseRunStatus.feedback)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFeedbackText(exerciseState),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () => exerciseController.goToNext(
                                totalQuestions: totalQuestions,
                              ),
                              child: Text(
                                currentIndex == totalQuestions - 1
                                    ? "Lihat Hasil"
                                    : "Soal Berikutnya",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Terjadi error: $error')),
        ),
      ),
    );
  }

  Widget _buildExerciseContent(
    Exercise exercise,
    ExerciseState exerciseState,
    void Function(bool isCorrect) onSubmit,
  ) {
    switch (exercise.type) {
      case ExerciseType.translation:
        final data = exercise.translation!;
        return TranslationExerciseView(
          key: ValueKey(exercise.id),
          data: data,
          state: exerciseState,
          onSubmit: onSubmit,
        );

      case ExerciseType.wordTiles:
        final data = exercise.wordTiles!;
        return WordTilesExerciseView(
          key: ValueKey(exercise.id),
          data: data,
          state: exerciseState,
          onSubmit: onSubmit,
        );

      case ExerciseType.pictureSelection:
        final data = exercise.pictureSelection!;
        return PictureSelectionExerciseView(
          key: ValueKey(exercise.id),
          data: data,
          state: exerciseState,
          onSubmit: onSubmit,
        );
    }
  }

  Widget _buildFeedbackText(ExerciseState state) {
    final isCorrect = state.lastAnswerCorrect ?? false;
    final text = isCorrect ? 'Jawaban kamu BENAR' : 'Jawaban kamu SALAH';
    final color = isCorrect ? Colors.green : Colors.red;

    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildSummaryView({
    required BuildContext context,
    required ExerciseState state,
    required int totalQuestions,
    required VoidCallback onRestart,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lesson Selesai',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Benar: ${state.correctCount}\n'
              'Salah: ${state.wrongCount}\n'
              'Total Soal: $totalQuestions',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRestart,
              child: const Text('Ulangi Lesson'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                context.goNamed(AppRoute.lessons.name);
              },
              child: const Text('Kembali ke daftar lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
