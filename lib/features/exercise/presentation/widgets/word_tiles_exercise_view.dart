import 'package:flutter/material.dart';
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
          "Tipe: Word Tiles",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Susun kata-kata berikut menjadi kalimat yang benar",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: _selectedTokens.isEmpty
              ? const Text(
                  'Tap kata-kata di bawah untu menyusun kalimat',
                  style: TextStyle(color: Colors.grey),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTokens
                      .map((token) => Chip(label: Text(token)))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTokens.map((token) {
            final isDistractor = !widget.data.correctTokens.contains(token);

            return ChoiceChip(
              label: Text(token),
              selected: false,
              onSelected: isAnswering
                  ? (_) {
                      setState(() {
                        _availableTokens.remove(token);
                        _selectedTokens.add(token);
                      });
                    }
                  : null,
              backgroundColor: isDistractor
                  ? Colors.grey.shade200
                  : Colors.blue.shade50,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        if (isAnswering)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectedTokens.isEmpty
                      ? null
                      : () {
                          setState(() {
                            final last = _selectedTokens.removeLast();
                            _availableTokens.add(last);
                          });
                        },
                  child: const Text('Undo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _resetTokens();
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedTokens.isEmpty
                      ? null
                      : () {
                          final isCorrect = _checkAnswer();
                          widget.onSubmit(isCorrect);
                        },
                  child: const Text('Submit'),
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kalimat yang benar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.data.correctSentence,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
      ],
    );
  }

  bool _checkAnswer() {
    final correct = widget.data.correctTokens;

    if (_selectedTokens.length != correct.length) {
      return false;
    }

    for (var i = 0; i < correct.length; i++) {
      if (_selectedTokens[i] != correct[i]) {
        return false;
      }
    }
    return true;
  }
}
