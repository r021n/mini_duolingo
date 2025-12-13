import 'package:mini_duolingo/data/models/exercise.dart';
import 'package:mini_duolingo/data/models/lesson.dart';
import 'package:mini_duolingo/data/models/unit.dart';
import 'package:mini_duolingo/data/models/course.dart';

// Language & Course

const String l1Indonesian = 'id';
const String l2English = 'en';

final Course demoCourse = Course(
  id: 'en_for_id',
  title: 'English for Indonesian',
  description: 'Belajar bahasa Inggris dasar untuk penutur bahasa Indonesia.',
  fromLanguageCode: l1Indonesian,
  learningLanguageCode: l2English,
  units: [Unit(id: 'unit-1', title: 'Dasar 1', lessons: [])],
);

// Lessons & Exercises

final List<Lesson> dummyLessons = [
  Lesson(
    id: 'greetings-1',
    title: 'Greetings 1',
    description: 'Sapaan dasar dalam bahasa Inggris.',
    exercises: [
      Exercise(
        id: 'greetings-1-ex-1',
        type: ExerciseType.translation,
        translation: TranslationExerciseData(
          prompt: 'Good morning',
          correctAnswers: ['selamat pagi', 'pagi'],
          options: [
            'selamat pagi',
            'selamat malam',
            'sampai jumpa',
            'terima kasih',
          ],
        ),
      ),
      Exercise(
        id: 'greetings-1-ex-2',
        type: ExerciseType.wordTiles,
        wordTiles: WordTilesExerciseData(
          correctSentence: 'How are you?',
          correctTokens: ['How', 'are', 'you', '?'],
          allTokens: ['How', 'are', 'you', '?', 'today'],
        ),
      ),
      Exercise(
        id: 'greetings-1-ex-3',
        type: ExerciseType.pictureSelection,
        pictureSelection: PictureSelectionExerciseData(
          word: 'apple',
          imageOptions: [
            'assets/images/apple.png',
            'assets/images/banana.png',
            'assets/images/orange.png',
          ],
          correctIndex: 0,
        ),
      ),
    ],
  ),
  Lesson(
    id: 'nouns-1',
    title: 'Basic Nouns',
    description: 'Kata benda umum dalam kehidupan sehari-hari.',
    exercises: [
      Exercise(
        id: 'nouns-1-ex-1',
        type: ExerciseType.translation,
        translation: TranslationExerciseData(
          prompt: 'The dog',
          correctAnswers: ['anjing itu', 'si anjing'],
          options: ['anjing itu', 'kucing itu', 'burung itu'],
        ),
      ),
      Exercise(
        id: 'nouns-1-ex-2',
        type: ExerciseType.wordTiles,
        wordTiles: WordTilesExerciseData(
          correctSentence: 'The cat is sleeping.',
          correctTokens: ['The', 'cat', 'is', 'sleeping', '.'],
          allTokens: ['The', 'cat', 'is', 'sleeping', '.', 'fast'],
        ),
      ),
    ],
  ),
  Lesson(
    id: 'verbs-1',
    title: 'Basic Verbs',
    description: 'Kata kerja dasar dan contoh penggunaannya.',
    exercises: [
      Exercise(
        id: 'verbs-1-ex-1',
        type: ExerciseType.translation,
        translation: TranslationExerciseData(
          prompt: 'I eat rice',
          correctAnswers: ['saya makan nasi', 'aku makan nasi'],
          options: ['saya makan nasi', 'saya minum air', 'saya tidur'],
        ),
      ),
      Exercise(
        id: 'verbs-1-ex-2',
        type: ExerciseType.wordTiles,
        wordTiles: WordTilesExerciseData(
          correctSentence: 'They are playing football.',
          correctTokens: ['They', 'are', 'playing', 'football', '.'],
          allTokens: ['They', 'are', 'playing', 'football', '.', 'now'],
        ),
      ),
      Exercise(
        id: 'verbs-1-ex-3',
        type: ExerciseType.pictureSelection,
        pictureSelection: PictureSelectionExerciseData(
          word: 'drink',
          imageOptions: [
            'assets/images/drink.png',
            'assets/images/eat.png',
            'assets/images/sleep.png',
          ],
          correctIndex: 0,
        ),
      ),
    ],
  ),
];
