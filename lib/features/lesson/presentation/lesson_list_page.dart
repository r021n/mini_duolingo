import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonListPage extends StatelessWidget {
  const LessonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = ['lesson-1', 'lesson-2', 'lesson-3'];

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Lesson')),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lessonId = lessons[index];
          return ListTile(
            title: Text('Lesson: ${lessonId.toUpperCase()}'),
            subtitle: const Text('Placeholder Lesson'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/exercise/$lessonId');
            },
          );
        },
      ),
    );
  }
}
