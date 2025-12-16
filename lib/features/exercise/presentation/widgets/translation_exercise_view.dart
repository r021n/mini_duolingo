import 'package:flutter/material.dart';
import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/features/exercise/application/exercise_controller.dart';

class TranslationExerciseView extends StatefulWidget {
  final TranslationExerciseData data;
  final ExerciseState state;
  final void Function(bool isCorrect) onSubmit;

  const TranslationExerciseView({
    super.key,
    required this.data,
    required this.state,
    required this.onSubmit,
  });

  @override
  State<TranslationExerciseView> createState() =>
      _TranslationExerciseViewState();
}

class _TranslationExerciseViewState extends State<TranslationExerciseView> {
  String _userInput = '';

  @override
  Widget build(BuildContext context) {
    final isAnswering = widget.state.status == ExerciseRunStatus.answering;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe: Translation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Terjemahkan kalimat ini ke bahasa Indonesia',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '"${widget.data.prompt}"',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(
          enabled: isAnswering,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Jawaban kamu (Bahasa Indonesia)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _userInput = value;
            });
          },
        ),
        const SizedBox(height: 12),

        if (isAnswering)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _userInput.trim().isEmpty
                  ? null
                  : () {
                      final isCorrect = _checkAnswer(
                        _userInput,
                        widget.data.correctAnswers,
                      );
                      widget.onSubmit(isCorrect);
                    },
              child: const Text('Submit'),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Contoh jawaban benar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '- ${widget.data.correctAnswers.first}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
      ],
    );
  }

  bool _checkAnswer(String input, List<String> correctAnswers) {
    final normalizedUser = _normalize(input);
    for (final ans in correctAnswers) {
      if (normalizedUser == _normalize(ans)) {
        return true;
      }
    }
    return false;
  }

  String _normalize(String value) {
    final lower = value.toLowerCase().trim();
    final withoutPunctuation = lower.replaceAll(RegExp(r'[^\w\s]'), '');
    return withoutPunctuation.replaceAll(RegExp(r'\s+'), ' ');
  }
}
