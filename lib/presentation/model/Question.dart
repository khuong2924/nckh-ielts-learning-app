class Question {
  final String id;
  final String text;
  final List<String>? options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.text,
    this.options,
    required this.correctAnswer,
  });
}