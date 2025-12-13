import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_duolingo/data/models/lesson.dart';
import 'package:mini_duolingo/data/repositories/lesson_repository.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return DummyLessonRepository();
});

final lessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getLessons();
});

final lessonByIdProvider = FutureProvider.family<Lesson?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getLessonById(id);
});
