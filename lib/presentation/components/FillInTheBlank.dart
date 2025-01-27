import 'package:flutter/material.dart';
class FillInTheBlankQuestion extends StatelessWidget {
  final String questionText;
  final String initialAnswer;
  final ValueChanged<String?> onAnswerSubmitted;

  const FillInTheBlankQuestion({
    Key? key,
    required this.questionText,
    required this.initialAnswer,
    required this.onAnswerSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: initialAnswer);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(questionText, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          TextField(
            controller: _controller,
            onChanged: (value) => onAnswerSubmitted(value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your answer',
            ),
          ),
        ],
      ),
    );
  }
}
