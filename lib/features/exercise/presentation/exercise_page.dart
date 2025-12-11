import 'package:flutter/material.dart';

class ExercisePage extends StatelessWidget {
  final String lessonId;

  const ExercisePage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise - $lessonId')),
      body: Center(
        child: Text(
          'Exercise placeholder untuk $lessonId',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
