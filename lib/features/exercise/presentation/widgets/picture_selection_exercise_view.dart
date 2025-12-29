import 'package:flutter/material.dart';
import 'package:mini_duolingo/core/theme/app_theme.dart';
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '"${widget.data.word}"',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.data.imageOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final imagePath = widget.data.imageOptions[index];
            final isSelected = _selectedIndex == index;

            Color borderColor = Colors.grey.shade300;
            Color bgColor = Colors.white;
            double borderWidth = 2;

            if (isFeedback) {
              if (index == widget.data.correctIndex) {
                borderColor = AppTheme.greenPrimary;
                bgColor = AppTheme.greenPrimary.withValues(alpha: 0.1);
                borderWidth = 3;
              } else if (_selectedIndex != null &&
                  index == _selectedIndex &&
                  _selectedIndex != widget.data.correctIndex) {
                borderColor = Colors.red;
                bgColor = Colors.red.withValues(alpha: 0.1);
                borderWidth = 3;
              }
            } else if (isSelected) {
              borderColor = Colors.blue;
              bgColor = AppTheme.blueSky.withValues(alpha: 0.2);
              borderWidth = 3;
            }

            return GestureDetector(
              onTap: isAnswering
                  ? () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: borderWidth),
                  boxShadow: isSelected && isAnswering
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(imagePath, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
              onPressed: _selectedIndex == null
                  ? null
                  : () => widget.onSubmit(
                      _selectedIndex == widget.data.correctIndex,
                    ),
              child: const Text(
                'Cek Jawaban',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
