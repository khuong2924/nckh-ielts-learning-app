class Vocabulary {
  final String id;
  final String englishWord;
  final String meaning;
  final String? vietnameseWord;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? example;
  final String? imageUrl;
  final String? audioUrl;

  bool isLearned;
  bool isFavorite;

  Vocabulary({
    required this.id,
    required this.englishWord,
    required this.meaning,
    this.vietnameseWord,
    this.pronunciation,
    this.partOfSpeech,
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
      meaning: meaning,
      vietnameseWord: vietnameseWord,
      pronunciation: pronunciation,
      partOfSpeech: partOfSpeech,
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
      meaning: map['meaning'] as String,
      vietnameseWord: map['vietnameseWord'] as String?,
      pronunciation: map['pronunciation'] as String?,
      partOfSpeech: map['part_of_speech'] as String?,
      example: map['example'] as String?,
      audioUrl: map['audio_url'] as String?,
      imageUrl: map['image_url'] as String?,
      isLearned: map['is_learned'] as bool? ?? false,
      isFavorite: map['is_favorite'] as bool? ?? false,
    );
  }
}