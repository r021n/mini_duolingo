import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/core/routing/app_router.dart';
import 'package:mini_duolingo/core/theme/app_theme.dart';
import 'package:mini_duolingo/data/lesson_providers.dart';
import 'package:mini_duolingo/data/user_progress_providers.dart';

class LessonListPage extends ConsumerWidget {
  const LessonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final progressAsync = ref.watch(userProgressProvider);

    final progress = progressAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textDark,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Peta Belajar",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: AppTheme.textDark,
            fontSize: 24,
          ),
        ),
      ),
      body: lessonsAsync.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return const Center(child: Text('Belum ada lesson'));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isCompleted =
                  progress?.completedLessonIds.contains(lesson.id) ?? false;

              bool isUnlocked = true;
              if (index > 0) {
                final previousLesson = lessons[index - 1];
                final prefCompleted =
                    progress?.completedLessonIds.contains(previousLesson.id) ??
                    false;
                isUnlocked = prefCompleted;
              }

              _LessonStatus status;

              if (!isUnlocked) {
                status = _LessonStatus.locked;
              } else if (isCompleted) {
                status = _LessonStatus.completed;
              } else {
                status = _LessonStatus.active;
              }

              return _LessonPathItem(
                index: index,
                title: lesson.title,
                status: status,
                isLastItem: index == lessons.length - 1,
                onTap: () {
                  if (status == _LessonStatus.locked) {
                    _showLockedDialog(context);
                    return;
                  }
                  context.goNamed(
                    AppRoute.lessonExercise.name,
                    pathParameters: {'lessonId': lesson.id},
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.greenPrimary),
        ),
        error: (error, stackTrace) =>
            Center(child: Text('Terjadi error: $error')),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Level Terkunci',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Selesaikan level sebelumnya untuk membuka level ini',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OKE",
              style: TextStyle(
                color: AppTheme.greenPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _LessonStatus { locked, active, completed }

class _LessonPathItem extends StatelessWidget {
  final int index;
  final String title;
  final _LessonStatus status;
  final bool isLastItem;
  final VoidCallback onTap;

  const _LessonPathItem({
    required this.index,
    required this.title,
    required this.status,
    required this.isLastItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalOffset = (index % 2 == 0) ? -30.0 : 30.0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(width: double.infinity, height: 120),
            if (!isLastItem)
              Positioned(
                top: 60,
                bottom: -60,
                child: Transform.translate(
                  offset: Offset(horizontalOffset * 0.5, 0),
                  child: Container(
                    width: 12,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

            Transform.translate(
              offset: Offset(horizontalOffset, 0),
              child: Column(
                children: [
                  _LevelButton3D(status: status, onTap: onTap),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: status == _LessonStatus.locked
                          ? Colors.grey
                          : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelButton3D extends StatefulWidget {
  final _LessonStatus status;
  final VoidCallback onTap;

  const _LevelButton3D({required this.status, required this.onTap});

  @override
  State<_LevelButton3D> createState() => __LevelButton3DState();
}

class __LevelButton3DState extends State<_LevelButton3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(widget.status);
    final size = widget.status == _LessonStatus.active ? 80.0 : 70.0;
    const double depth = 8.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() {
        _isPressed = false;
        widget.onTap();
      }),
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: size,
        height: size + depth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: _isPressed ? depth : depth,
              bottom: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _isPressed ? Colors.transparent : colors.pressed,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              top: _isPressed ? depth : 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _isPressed ? colors.pressed : colors.main,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(widget.status),
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            ),
            if (!_isPressed && widget.status != _LessonStatus.locked)
              Positioned(
                top: 10,
                left: 15,
                child: Container(
                  width: size * 0.2,
                  height: size * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ({Color main, Color shadow, Color pressed}) _getColors(_LessonStatus status) {
    switch (status) {
      case _LessonStatus.active:
        return (
          main: AppTheme.greenPrimary,
          shadow: AppTheme.greenDark,
          pressed: const Color(0xFF4CAF50),
        );
      case _LessonStatus.completed:
        return (
          main: AppTheme.yellowGold,
          shadow: const Color(0xFFCCAC00),
          pressed: const Color(0xFFFFE033),
        );
      case _LessonStatus.locked:
        return (
          main: const Color(0xFFE5E5E5),
          shadow: const Color(0xFFAFB2B1),
          pressed: const Color(0xFFE5E5E5),
        );
    }
  }

  IconData _getIcon(_LessonStatus status) {
    switch (status) {
      case _LessonStatus.active:
        return Icons.start_rounded;
      case _LessonStatus.completed:
        return Icons.check_rounded;
      case _LessonStatus.locked:
        return Icons.lock_rounded;
    }
  }
}
