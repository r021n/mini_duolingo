import 'package:flutter/material.dart';
import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/features/exercise/application/exercise_controller.dart';

class PictureSelectionExerciseView extends StatefulWidget {
  final PictureSelectionExerciseData data;
  final ExerciseState state;
  final void Function(bool isCorrect) onSubmit;

  const PictureSelectionExerciseView({
    super.key,
    required this.data,
    required this.state,
    required this.onSubmit,
  });

  @override
  State<PictureSelectionExerciseView> createState() =>
      _PictureSelectionExerciseViewState();
}

class _PictureSelectionExerciseViewState
    extends State<PictureSelectionExerciseView> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isAnswering = widget.state.status == ExerciseRunStatus.answering;
    final isFeedback = widget.state.status == ExerciseRunStatus.feedback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe: Picture Selection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih gambar yang sesuai dengan kata berikut',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '"${widget.data.word}"',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.data.imageOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final imagePath = widget.data.imageOptions[index];
            final isSelected = _selectedIndex == index;

            Color borderColor = Colors.grey.shade400;
            double borderWidth = 2;

            if (isFeedback) {
              if (index == widget.data.correctIndex) {
                borderColor = Colors.green;
                borderWidth = 3;
              } else if (_selectedIndex != null &&
                  index == _selectedIndex &&
                  _selectedIndex != widget.data.correctIndex) {
                borderColor = Colors.red;
                borderWidth = 3;
              }
            } else if (isSelected) {
              borderColor = Colors.blue;
              borderWidth = 3;
            }

            return InkWell(
              onTap: isAnswering
                  ? () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Text(
                            'Image\nnot found',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        if (isAnswering)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _selectedIndex == null
                  ? null
                  : () {
                      final isCorrect =
                          _selectedIndex == widget.data.correctIndex;
                      widget.onSubmit(isCorrect);
                    },
              child: const Text('Submit'),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Perhatikan highlight',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '-Hijau = jawaban benar\n'
                '-Merah = jawaban yang kamu pilih (jika salah)',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
      ],
    );
  }
}
