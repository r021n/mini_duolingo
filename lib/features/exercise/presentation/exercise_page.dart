import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/core/routing/app_router.dart';
import 'package:mini_duolingo/core/theme/app_theme.dart';
import 'package:mini_duolingo/data/lesson_providers.dart';
import 'package:mini_duolingo/data/user_progress_providers.dart';
import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/features/exercise/application/exercise_controller.dart';
import 'package:mini_duolingo/features/exercise/presentation/widgets/translation_exercise_view.dart';
import 'package:mini_duolingo/features/exercise/presentation/widgets/word_tiles_exercise_view.dart';
import 'package:mini_duolingo/features/exercise/presentation/widgets/picture_selection_exercise_view.dart';

class ExercisePage extends ConsumerWidget {
  final String lessonId;
  const ExercisePage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExerciseState>(exerciseControllerProvider, (previous, next) {
      final wasCompleted = previous?.status == ExerciseRunStatus.completed;
      final isCompleted = next.status == ExerciseRunStatus.completed;
      if (!wasCompleted && isCompleted) {
        final correctAnswers = next.correctCount;
        ref
            .read(userProgressProvider.notifier)
            .applyLessonCompletion(
              lessonId: lessonId,
              correctAnswers: correctAnswers,
            );
      }
    });

    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));
    final exerciseState = ref.watch(exerciseControllerProvider);
    final exerciseController = ref.read(exerciseControllerProvider.notifier);

    return WillPopScope(
      onWillPop: () async => await _onWillPop(context, exerciseState),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: lessonAsync.when(
            data: (lesson) {
              if (lesson == null || lesson.exercises.isEmpty) {
                return const Center(child: Text('Lesson tidak valid.'));
              }

              final totalQuestions = lesson.exercises.length;

              if (exerciseState.status == ExerciseRunStatus.completed) {
                return _buildSummaryView(
                  context: context,
                  state: exerciseState,
                  totalQuestions: totalQuestions,
                  onRestart: exerciseController.restartLesson,
                );
              }

              final currentIndex = exerciseState.currentIndex.clamp(
                0,
                totalQuestions - 1,
              );
              final currentExercise = lesson.exercises[currentIndex];
              final isFeedback =
                  exerciseState.status == ExerciseRunStatus.feedback;
              final isCorrect = exerciseState.lastAnswerCorrect ?? false;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 32,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            if (await _onWillPop(context, exerciseState)) {
                              context.pop();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AnimatedProgressBar(
                            current: currentIndex,
                            total: totalQuestions,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildExerciseContent(
                        currentExercise,
                        exerciseState,
                        (isCorrect) {
                          exerciseController.submitAnswer(isCorrect: isCorrect);
                        },
                      ),
                    ),
                  ),

                  _buildBottomActionArea(
                    context: context,
                    isFeedback: isFeedback,
                    isCorrect: isCorrect,
                    exerciseState: exerciseState,
                    onCheckPressed: () {},
                    onContinuePressed: () => exerciseController.goToNext(
                      totalQuestions: totalQuestions,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context, ExerciseState state) async {
    if (state.status == ExerciseRunStatus.completed) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sudahan dulu?'),
            content: const Text(
              'Progress lesson ini akan hilang jika kamu keluar sekarang.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'LANJUT',
                  style: TextStyle(
                    color: AppTheme.greenPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'KELUAR',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildExerciseContent(
    Exercise exercise,
    ExerciseState exerciseState,
    void Function(bool isCorrect) onSubmit,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(exercise.id),
        child: Builder(
          builder: (context) {
            switch (exercise.type) {
              case ExerciseType.translation:
                return TranslationExerciseView(
                  data: exercise.translation!,
                  state: exerciseState,
                  onSubmit: onSubmit,
                );
              case ExerciseType.wordTiles:
                return WordTilesExerciseView(
                  data: exercise.wordTiles!,
                  state: exerciseState,
                  onSubmit: onSubmit,
                );
              case ExerciseType.pictureSelection:
                return PictureSelectionExerciseView(
                  data: exercise.pictureSelection!,
                  state: exerciseState,
                  onSubmit: onSubmit,
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBottomActionArea({
    required BuildContext context,
    required bool isFeedback,
    required bool isCorrect,
    required ExerciseState exerciseState,
    required VoidCallback onCheckPressed,
    required VoidCallback onContinuePressed,
  }) {
    if (isFeedback) {
      final color = isCorrect
          ? const Color(0xFFd7ffb8)
          : const Color(0xFFFFDFE0);
      final textColor = isCorrect
          ? const Color(0xFF58a700)
          : const Color(0xFFEA2B2B);
      final title = isCorrect ? 'Hebat!' : 'Yah, kurang tepat...';
      final icon = isCorrect ? Icons.check_circle : Icons.cancel;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 30),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _Global3DButton(
                text: 'LANJUT',
                color: isCorrect
                    ? AppTheme.greenPrimary
                    : const Color(0xFFFF4B4B),
                shadowColor: isCorrect
                    ? AppTheme.greenDark
                    : const Color(0xFFEA2B2B),
                onPressed: onContinuePressed,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSummaryView({
    required BuildContext context,
    required ExerciseState state,
    required int totalQuestions,
    required VoidCallback onRestart,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 100,
            color: AppTheme.yellowGold,
          ),
          const SizedBox(height: 24),
          const Text(
            'Lesson Selesai!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Benar', '${state.correctCount}', Colors.green),
                Container(width: 2, height: 40, color: Colors.grey.shade300),
                _buildStatItem('Salah', '${state.wrongCount}', Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: _Global3DButton(
              text: 'ULANGI LESSON',
              color: AppTheme.blueSky,
              shadowColor: Colors.blue.shade300,
              textColor: Colors.blue.shade900,
              onPressed: onRestart,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _Global3DButton(
              text: 'SELESAI',
              color: AppTheme.greenPrimary,
              shadowColor: AppTheme.greenDark,
              onPressed: () => context.goNamed(AppRoute.lessons.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _AnimatedProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final double percentage = (current / total).clamp(0.0, 1.0);
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greenPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Button Reuse Global untuk Exercise
class _Global3DButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;

  const _Global3DButton({
    required this.text,
    required this.onPressed,
    this.color = AppTheme.greenPrimary,
    this.shadowColor = AppTheme.greenDark,
    this.textColor = Colors.white,
  });

  @override
  State<_Global3DButton> createState() => _Global3DButtonState();
}

class _Global3DButtonState extends State<_Global3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final bgColor = isDisabled ? Colors.grey.shade300 : widget.color;
    final shadowColor = isDisabled ? Colors.grey.shade400 : widget.shadowColor;
    final textColor = isDisabled ? Colors.grey.shade500 : widget.textColor;

    const double height = 50;
    const double depth = 4;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        height: height + depth,
        child: Stack(
          children: [
            Positioned(
              top: depth,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Positioned(
              top: _isPressed ? depth : 0,
              bottom: _isPressed ? 0 : depth,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.text.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
