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

class FlashcardProgress {
  final int id;             // SERIAL (auto-incremented integer)
  final String userId;      // UUID (Firebase UID)
  final String flashcardId;  // UUID
  final int progress;       // INT

  FlashcardProgress({
    required this.id,
    required this.userId,
    required this.flashcardId,
    this.progress = 0,
  });

  // Factory method to create a FlashcardProgress from a map
  factory FlashcardProgress.fromMap(Map<String, dynamic> map) {
    return FlashcardProgress(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      flashcardId: map['flashcard_id'] as String,
      progress: map['progress'] as int,
    );
  }
}