class FlashCard {
  final String id;
  final String title;
  final String author;
  final int totalWords;
  final int currentProgress;
  final int maxProgress;

  FlashCard({
    required this.id,
    required this.title,
    required this.author,
    required this.totalWords,
    required this.currentProgress,
    required this.maxProgress,
  });

  // Thêm factory constructor để parse từ JSON nếu cần
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      totalWords: json['totalWords'],
      currentProgress: json['currentProgress'],
      maxProgress: json['maxProgress'],
    );
  }
}