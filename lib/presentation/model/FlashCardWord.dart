// Tạo thêm model cho từng từ trong flashcard
class FlashcardWord {
  final String englishWord;
  final String vietnameseWord;
  final String pronunciation;
  final String description;
  final String imageUrl;
  final String audioUrl;
  bool isLearned;

  FlashcardWord({
    required this.englishWord,
    required this.vietnameseWord,
    required this.pronunciation,
    required this.description,
    required this.imageUrl,
    this.audioUrl = '',
    this.isLearned = false,
  });
}