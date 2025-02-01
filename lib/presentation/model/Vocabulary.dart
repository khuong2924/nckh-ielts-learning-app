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
}