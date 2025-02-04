class Vocabulary {
  final String id; // Thêm thuộc tính id
  final String englishWord;
  final String vietnameseWord;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? meaning;
  final String? example;
  final String? audioUrl;

  bool isLearned; // Thêm thuộc tính isLearned
  bool isFavorite; // Thêm thuộc tính isFavorite

  Vocabulary({
    required this.id, // Thêm id vào constructor
    required this.englishWord,
    required this.vietnameseWord,
    this.pronunciation,
    this.partOfSpeech,
    this.meaning,
    this.example,
    this.audioUrl,
    this.isLearned = false, // Mặc định là false
    this.isFavorite = false, // Mặc định là false
  });

  Vocabulary copyWith({
    bool? isLearned,
    bool? isFavorite,
  }) {
    return Vocabulary(
      id: id, // Bảo toàn id
      englishWord: englishWord,
      vietnameseWord: vietnameseWord,
      pronunciation: pronunciation,
      partOfSpeech: partOfSpeech,
      meaning: meaning,
      example: example,
      audioUrl: audioUrl,
      isLearned: isLearned ?? this.isLearned, // Cập nhật isLearned nếu có
      isFavorite: isFavorite ?? this.isFavorite, // Cập nhật isFavorite nếu có
    );
  }
}