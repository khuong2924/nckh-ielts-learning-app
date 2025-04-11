class Flashcard {
  final String id;          // UUID
  final String topic;       // TEXT
  final int totalWords;     // INT
  final DateTime createdAt; // TIMESTAMP

  Flashcard({
    required this.id,
    required this.topic,
    required this.totalWords,
    required this.createdAt,
  });

  // Factory method to create a Flashcard from a map
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      topic: map['topic'] as String,
      totalWords: map['total_words'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
