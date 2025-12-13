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
}
