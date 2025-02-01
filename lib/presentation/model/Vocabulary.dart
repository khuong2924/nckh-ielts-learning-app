class Vocabulary {
  final String englishWord;
  final String vietnameseWord;
  final bool isLearned;
  final bool isFavorite;

  Vocabulary({
    required this.englishWord,
    required this.vietnameseWord,
    this.isLearned = false,
    this.isFavorite = false,
  });

  Vocabulary copyWith({
    String? englishWord,
    String? vietnameseWord,
    bool? isLearned,
    bool? isFavorite,
  }) {
    return Vocabulary(
      englishWord: englishWord ?? this.englishWord,
      vietnameseWord: vietnameseWord ?? this.vietnameseWord,
      isLearned: isLearned ?? this.isLearned,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}