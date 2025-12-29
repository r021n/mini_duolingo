import 'package:flutter/material.dart';
import 'package:mini_duolingo/core/theme/app_theme.dart';
import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/features/exercise/application/exercise_controller.dart';

class WordTilesExerciseView extends StatefulWidget {
  final WordTilesExerciseData data;
  final ExerciseState state;
  final void Function(bool isCorrect) onSubmit;

  const WordTilesExerciseView({
    super.key,
    required this.data,
    required this.state,
    required this.onSubmit,
  });

  @override
  State<WordTilesExerciseView> createState() => _WordTilesExerciseViewState();
}

class _WordTilesExerciseViewState extends State<WordTilesExerciseView> {
  late List<String> _availableTokens;
  final List<String> _selectedTokens = [];

  @override
  void initState() {
    super.initState();
    _resetTokens();
  }

  void _resetTokens() {
    _availableTokens = List<String>.from(widget.data.allTokens);
    _availableTokens.shuffle();
    _selectedTokens.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isAnswering = widget.state.status == ExerciseRunStatus.answering;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Susun kalimat ini",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 32),

        // Area Jawaban (Garis-garis / Kotak Kosong)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            children: _selectedTokens.map((token) {
              return GestureDetector(
                onTap: isAnswering
                    ? () => setState(() {
                        _selectedTokens.remove(token);
                        _availableTokens.add(token);
                      })
                    : null,
                child: _WordTile(text: token, isSelected: true),
              );
            }).toList(),
          ),
        ),

        // Garis pembatas area jawaban
        Divider(color: Colors.grey.shade300, thickness: 2, height: 40),

        // Area Pilihan Kata
        Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _availableTokens.map((token) {
              return GestureDetector(
                onTap: isAnswering
                    ? () => setState(() {
                        _availableTokens.remove(token);
                        _selectedTokens.add(token);
                      })
                    : null,
                child: _WordTile(text: token, isSelected: false),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

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
              onPressed: _selectedTokens.isEmpty
                  ? null
                  : () {
                      final isCorrect = _checkAnswer();
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
        else if (widget.state.lastAnswerCorrect == false)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Jawaban benar: ${widget.data.correctSentence}",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  bool _checkAnswer() {
    final correct = widget.data.correctTokens;
    if (_selectedTokens.length != correct.length) return false;
    for (var i = 0; i < correct.length; i++) {
      if (_selectedTokens[i] != correct[i]) return false;
    }
    return true;
  }
}

// Widget Kecil untuk Kotak Kata (Tile)
class _WordTile extends StatelessWidget {
  final String text;
  final bool
  isSelected; // Jika selected, tampilkan di atas, jika false tampil di bank kata

  const _WordTile({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 3), // Efek 3D simple
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
    );
  }
}
