enum ExerciseType { translation, wordTiles, pictureSelection }

class TranslationExerciseData {
  final String prompt;
  final List<String> correctAnswers;
  final List<String>? options;

  const TranslationExerciseData({
    required this.prompt,
    required this.correctAnswers,
    this.options,
  });
}

class WordTilesExerciseData {
  final String correctSentence;
  final List<String> correctTokens;
  final List<String> allTokens;

  const WordTilesExerciseData({
    required this.correctSentence,
    required this.correctTokens,
    required this.allTokens,
  });
}

class PictureSelectionExerciseData {
  final String word;
  final List<String> imageOptions;
  final int correctIndex;

  const PictureSelectionExerciseData({
    required this.word,
    required this.imageOptions,
    required this.correctIndex,
  });
}

class Exercise {
  final String id;
  final ExerciseType type;

  final TranslationExerciseData? translation;
  final WordTilesExerciseData? wordTiles;
  final PictureSelectionExerciseData? pictureSelection;

  const Exercise({
    required this.id,
    required this.type,
    this.translation,
    this.wordTiles,
    this.pictureSelection,
  });
}
