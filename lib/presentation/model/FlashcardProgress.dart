
class FlashcardProgress {
  final int id;             // SERIAL (auto-incremented integer)
  final String userId;      // UUID (Firebase UID)
  final String flashcardId; // UUID
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