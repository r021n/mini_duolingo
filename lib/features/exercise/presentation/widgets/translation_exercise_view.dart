import 'package:flutter/material.dart';
import 'package:mini_duolingo/core/theme/app_theme.dart';
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
          'Terjemahkan kalimat ini',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 24),

        // Ilustrasi + Speech Bubble
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(
              Icons.face_rounded,
              size: 60,
              color: AppTheme.greenPrimary,
            ), // Placeholder Mascot
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                  ),
                ),
                child: Text(
                  widget.data.prompt,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        TextField(
          enabled: isAnswering,
          maxLines: 3,
          style: const TextStyle(fontSize: 18, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: 'Tulis dalam Bahasa Indonesia...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.greenPrimary,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) => setState(() => _userInput = value),
        ),

        const SizedBox(height: 32),

        if (isAnswering)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenPrimary,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _userInput.trim().isEmpty
                  ? null
                  : () {
                      final isCorrect = _checkAnswer(
                        _userInput,
                        widget.data.correctAnswers,
                      );
                      widget.onSubmit(isCorrect);
                    },
              child: const Text(
                'CEK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
        // Tampilkan Jawaban Benar jika User Salah (di UI Feedback)
        if (widget.state.lastAnswerCorrect == false)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jawaban yang benar:",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.data.correctAnswers.first,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _checkAnswer(String input, List<String> correctAnswers) {
    final normalizedUser = _normalize(input);
    for (final ans in correctAnswers) {
      if (normalizedUser == _normalize(ans)) return true;
    }
    return false;
  }

  String _normalize(String value) {
    final lower = value.toLowerCase().trim();
    final withoutPunctuation = lower.replaceAll(RegExp(r'[^\w\s]'), '');
    return withoutPunctuation.replaceAll(RegExp(r'\s+'), ' ');
  }
}
