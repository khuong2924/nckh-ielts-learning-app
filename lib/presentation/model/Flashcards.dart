class Flashcard {
  final String id;
  final String topic;
  final int totalWords;
  final DateTime createdAt;
  final String? author; // ← allow nullable

  Flashcard({
    required this.id,
    required this.topic,
    required this.totalWords,
    required this.createdAt,
    this.author, // ← nullable
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      topic: map['topic'] as String,
      totalWords: map['total_words'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      author: map['author'] as String?, // ← safe cast
    );
  }
}
