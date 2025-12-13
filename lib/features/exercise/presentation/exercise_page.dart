import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_duolingo/data/lesson_providers.dart';

class ExercisePage extends ConsumerWidget {
  final String lessonId;

  const ExercisePage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: Text('Exercise - $lessonId')),
      body: lessonAsync.when(
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson tidak ditemukan'));
          }

          return Center(
            child: Text(
              'Exercise placeholder untuk "${lesson.title}"\n'
              'Jumlah soal: ${lesson.exercises.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Terjadi error: $error')),
      ),
    );
  }
}
