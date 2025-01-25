class Question {
  final String text;
  final List<Map<String, dynamic>> options;
  final String type;
  final int id;

  Question({
    required this.text,
    required this.options,
    required this.type,
    required this.id,
  });

  // Phương thức từ Map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['question_text'] ?? '',
      options: List<Map<String, dynamic>>.from(map['options'] ?? []),
      type: map['type'] ?? '',
      id: map['id'] ?? 0,
    );
  }
}