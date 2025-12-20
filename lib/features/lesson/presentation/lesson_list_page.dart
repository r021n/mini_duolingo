import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/core/routing/app_router.dart';
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

              bool isUnlocked = true;
              if (index > 0) {
                final previousLesson = lessons[index - 1];
                final prefCompleted =
                    progress?.completedLessonIds.contains(previousLesson.id) ??
                    false;
                isUnlocked = prefCompleted;
              }

              IconData leadingIcon;
              Color leadingColor;

              if (!isUnlocked) {
                leadingIcon = Icons.lock;
                leadingColor = Colors.grey;
              } else if (isCompleted) {
                leadingIcon = Icons.check_circle;
                leadingColor = Colors.green;
              } else {
                leadingIcon = Icons.radio_button_unchecked;
                leadingColor = Colors.grey;
              }

              return ListTile(
                leading: Icon(leadingIcon, color: leadingColor),
                title: Text(lesson.title),
                subtitle: Text(lesson.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (!isUnlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Selesaikan lesson sebelumnya untuk menyelesaikan lesson ini',
                        ),
                      ),
                    );
                    return;
                  }

                  context.goNamed(
                    AppRoute.lessonExercise.name,
                    pathParameters: {'lessonId': lesson.id},
                  );
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
