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

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? "",
      fromLanguageCode: json['fromLanguageCode'] as String,
      learningLanguageCode: json['learningLanguageCode'] as String,
      units: (json['units'] as List<dynamic>)
          .map((u) => Unit.fromJson(u as Map<String, dynamic>))
          .toList(),
    );
  }
}
