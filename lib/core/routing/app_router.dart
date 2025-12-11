import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/features/exercise/presentation/exercise_page.dart';
import 'package:mini_duolingo/features/home/presentation/home_page.dart';
import 'package:mini_duolingo/features/lesson/presentation/lesson_list_page.dart';
import 'package:mini_duolingo/features/splash/presentation/splash_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => SplashPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/lessons',
        name: 'lessons',
        builder: (context, state) => LessonListPage(),
      ),
      GoRoute(
        path: '/exercise/:lessonId',
        name: 'exercise',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return ExercisePage(lessonId: lessonId);
        },
      ),
    ],
  );
});
