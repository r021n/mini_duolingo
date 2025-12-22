import 'package:mini_duolingo/data/models/lesson.dart';

class Unit {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const Unit({required this.id, required this.title, required this.lessons});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      title: json['title'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
