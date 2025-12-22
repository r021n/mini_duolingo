import 'package:mini_duolingo/data/models/exercise.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
