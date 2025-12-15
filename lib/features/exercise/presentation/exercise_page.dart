import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/data/lesson_providers.dart';
import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/features/exercise/application/exercise_controller.dart';

class ExercisePage extends ConsumerWidget {
  final String lessonId;

  const ExercisePage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));
    final exerciseState = ref.watch(exerciseControllerProvider);
    final exerciseController = ref.watch(exerciseControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Lesson: $lessonId')),
      body: lessonAsync.when(
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson tidak ditemukan'));
          }

          if (lesson.exercises.isEmpty) {
            return const Center(child: Text('Lesson ini belum punya soal'));
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

                _buildExerciseContent(currentExercise),

                const Spacer(),

                if (exerciseState.status == ExerciseRunStatus.answering)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Simulasi jawaban (nanti diganti input beneran)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          exerciseController.submitAnswer(isCorrect: true);
                        },
                        child: const Text('Jawab benar'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          exerciseController.submitAnswer(isCorrect: false);
                        },
                        child: const Text('Jawab salah'),
                      ),
                    ],
                  ),

                if (exerciseState.status == ExerciseRunStatus.feedback)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildFeedbackText(exerciseState),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          exerciseController.goToNext(
                            totalQuestions: totalQuestions,
                          );
                        },
                        child: Text(
                          exerciseState.currentIndex == totalQuestions - 1
                              ? "Lihat Hasil"
                              : "Soal Berikutnya",
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Terjadi error: $error')),
      ),
    );
  }

  Widget _buildExerciseContent(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.translation:
        final data = exercise.translation;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipe: translation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terjemahkan kalimat ini ke bahasa indonesia:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '"${data?.prompt ?? '-'}"',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        );

      case ExerciseType.wordTiles:
        final data = exercise.wordTiles;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipe: Word Tiles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Susun kata kata berikut menjadi kalimat yang benar:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Target kalimat (sementara ditampilkan): "${data?.correctSentence ?? '-'}"',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (data?.allTokens ?? [])
                  .map((token) => Chip(label: Text(token)))
                  .toList(),
            ),
          ],
        );

      case ExerciseType.pictureSelection:
        final data = exercise.pictureSelection;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipe: Picture Selection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih gambar yang sesuai dengan kata berikut:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '"${data?.word ?? '-'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Untuk sementara, gambar belum ditampilkan - hanya teks placeholder',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
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
                context.go('/lessons');
              },
              child: const Text('Kembali ke daftar lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
