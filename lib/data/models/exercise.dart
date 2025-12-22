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

  factory TranslationExerciseData.fromJson(Map<String, dynamic> json) {
    return TranslationExerciseData(
      prompt: json['prompt'] as String,
      correctAnswers: (json['correctAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
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

  factory WordTilesExerciseData.fromJson(Map<String, dynamic> json) {
    return WordTilesExerciseData(
      correctSentence: json['correctSentence'] as String,
      correctTokens: (json['correctTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allTokens: (json['allTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
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

  factory PictureSelectionExerciseData.fromJson(Map<String, dynamic> json) {
    return PictureSelectionExerciseData(
      word: json['word'] as String,
      imageOptions: (json['imageOptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: json['correctIndex'] as int,
    );
  }
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

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = ExerciseType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => throw ArgumentError('Unknown exercise type $typeString'),
    );

    return Exercise(
      id: json['id'] as String,
      type: type,
      translation: json['translation'] != null
          ? TranslationExerciseData.fromJson(
              json['translation'] as Map<String, dynamic>,
            )
          : null,
      wordTiles: json['wordTiles'] != null
          ? WordTilesExerciseData.fromJson(
              json['wordTiles'] as Map<String, dynamic>,
            )
          : null,
      pictureSelection: json['pictureSelection'] != null
          ? PictureSelectionExerciseData.fromJson(
              json['pictureSelection'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
