import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/core/routing/app_router.dart';
import 'package:mini_duolingo/core/theme/app_theme.dart';
import 'package:mini_duolingo/data/user_progress_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, color: AppTheme.greenPrimary, size: 32),
            const SizedBox(width: 8),
            Text(
              'Mini Duolingo',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: AppTheme.greenPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
            tooltip: 'Reset Progress',
            onPressed: () async {
              _showResetDialog(context, ref);
            },
          ),
        ],
      ),
      body: progressAsync.when(
        data: (progress) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        color: AppTheme.orangeFire,
                        value: '${progress.currentStreak}',
                        label: 'Hari Streak',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.bolt_rounded,
                        color: AppTheme.yellowGold,
                        value: '${progress.totalXp}',
                        label: 'Total XP',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppTheme.blueSky.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_emotions_rounded,
                    size: 100,
                    color: AppTheme.greenPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Ayo belajar lagi!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Text(
                  "Selesaikan lesson hari ini untuk menjaga streakmu.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                _Custom3DButton(
                  onPressed: () {
                    context.goNamed(AppRoute.lessons.name);
                  },
                  text: 'MULAI BELAJAR',
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.greenPrimary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 10),
              Text('Ups! Ada masalah: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('Semua XP dan Streak akan kembali ke 0.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(userProgressProvider.notifier).resetProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress di-reset kembali ke 0'),
                  ),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Custom3DButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const _Custom3DButton({required this.onPressed, required this.text});

  @override
  State<_Custom3DButton> createState() => _Custom3DButtonState();
}

class _Custom3DButtonState extends State<_Custom3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color buttonColor = Color(0xFF58CC02);
    const Color shadowColor = Color(0xFF46A302);
    const Color pressedColor = Color(0xFF4CAF50);
    const double height = 56.0;
    const double depth = 8.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: _isPressed ? depth : depth,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _isPressed ? Colors.transparent : shadowColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Positioned(
              top: _isPressed ? depth : 0,
              left: 0,
              right: 0,
              bottom: _isPressed ? 0 : depth,
              child: Container(
                decoration: BoxDecoration(
                  color: _isPressed ? pressedColor : buttonColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = shadowColor,
                      ),
                    ),
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
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
      ),
    );
  }
}
