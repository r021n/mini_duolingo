import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/data/lesson_providers.dart';
import 'package:mini_duolingo/data/user_progress_providers.dart';

class LessonListPage extends ConsumerWidget {
  const LessonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final progressAsync = ref.watch(userProgressProvider);

    final progress = progressAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Lesson')),
      body: lessonsAsync.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return const Center(child: Text('Belum ada lesson'));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isCompleted =
                  progress?.completedLessonIds.contains(lesson.id) ?? false;
              return ListTile(
                leading: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(lesson.title),
                subtitle: Text(lesson.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/exercise/${lesson.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Terjadi error: $error')),
      ),
    );
  }
}
