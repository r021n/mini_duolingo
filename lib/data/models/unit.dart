import 'package:mini_duolingo/data/models/lesson.dart';

class Unit {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const Unit({required this.id, required this.title, required this.lessons});
}
