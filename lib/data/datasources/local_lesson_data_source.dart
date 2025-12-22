import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mini_duolingo/data/models/lesson.dart';
import 'package:mini_duolingo/data/models/course.dart';

class LocalLessonDataSource {
  final String assetPath;

  LocalLessonDataSource(this.assetPath);

  Course? _cachedCourse;

  Future<Course> _loadCourse() async {
    if (_cachedCourse != null) return _cachedCourse!;

    final jsonString = await rootBundle.loadString(assetPath);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    _cachedCourse = Course.fromJson(map);
    return _cachedCourse!;
  }

  Future<List<Lesson>> getLessons() async {
    final course = await _loadCourse();
    return course.units.expand((u) => u.lessons).toList();
  }

  Future<Lesson?> getLessonById(String id) async {
    final lessons = await getLessons();
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}
