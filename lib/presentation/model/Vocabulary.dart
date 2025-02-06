class Vocabulary {
  final String id;
  final String englishWord;
  final String vietnameseWord;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? meaning;
  final String? example;
  final String? imageUrl;
  final String? audioUrl;

  bool isLearned;
  bool isFavorite;

  Vocabulary({
    required this.id,
    required this.englishWord,
    required this.vietnameseWord,
    this.pronunciation,
    this.partOfSpeech,
    this.meaning,
    this.example,
    this.imageUrl,
    this.audioUrl,
    this.isLearned = false,
    this.isFavorite = false,
  });

  Vocabulary copyWith({
    bool? isLearned,
    bool? isFavorite,
  }) {
    return Vocabulary(
      id: id,
      englishWord: englishWord,
      vietnameseWord: vietnameseWord,
      pronunciation: pronunciation,
      partOfSpeech: partOfSpeech,
      meaning: meaning,
      example: example,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      isLearned: isLearned ?? this.isLearned,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] as String,
      englishWord: map['word'] as String,
      vietnameseWord: map['meaning'] as String, // Nếu bạn sử dụng nghĩa tiếng Việt ở đây
      pronunciation: map['pronunciation'] as String?,
      partOfSpeech: map['part_of_speech'] as String?,
      meaning: map['meaning'] as String?,
      example: map['example'] as String?,
      audioUrl: map['audio_url'] as String?,
      imageUrl: map['image_url'] as String?,
      isLearned: map['is_learned'] as bool? ?? false,
      isFavorite: map['is_favorite'] as bool? ?? false,
    );
  }
}