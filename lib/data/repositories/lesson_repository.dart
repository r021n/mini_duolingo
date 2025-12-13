import 'package:mini_duolingo/data/dummy_data.dart';
import 'package:mini_duolingo/data/models/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessons();
  Future<Lesson?> getLessonById(String id);
}

class DummyLessonRepository implements LessonRepository {
  @override
  Future<List<Lesson>> getLessons() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyLessons;
  }

  @override
  Future<Lesson?> getLessonById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final lesson in dummyLessons) {
      if (lesson.id == id) {
        return lesson;
      }
    }
    return null;
  }
}
