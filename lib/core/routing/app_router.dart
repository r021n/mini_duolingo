import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_duolingo/features/exercise/presentation/exercise_page.dart';
import 'package:mini_duolingo/features/home/presentation/home_page.dart';
import 'package:mini_duolingo/features/lesson/presentation/lesson_list_page.dart';
import 'package:mini_duolingo/features/splash/presentation/splash_page.dart';

enum AppRoute { splash, home, lessons, lessonExercise }

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash.name,
        builder: (context, state) => SplashPage(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/lessons',
        name: AppRoute.lessons.name,
        builder: (context, state) => LessonListPage(),
      ),
      GoRoute(
        path: '/exercise/:lessonId',
        name: AppRoute.lessonExercise.name,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return ExercisePage(lessonId: lessonId);
        },
      ),
    ],
  );
});
