import 'package:mini_duolingo/data/models/unit.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String fromLanguageCode;
  final String learningLanguageCode;
  final List<Unit> units;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.fromLanguageCode,
    required this.learningLanguageCode,
    required this.units,
  });
}
