// import 'package:mini_duolingo/data/dummy_data.dart';
import 'package:mini_duolingo/data/models/lesson.dart';
import 'package:mini_duolingo/data/datasources/local_lesson_data_source.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessons();
  Future<Lesson?> getLessonById(String id);
}

class LocalJsonLessonRepository implements LessonRepository {
  final LocalLessonDataSource _dataSource;

  LocalJsonLessonRepository(this._dataSource);

  @override
  Future<List<Lesson>> getLessons() {
    return _dataSource.getLessons();
  }

  @override
  Future<Lesson?> getLessonById(String id) {
    return _dataSource.getLessonById(id);
  }
}
