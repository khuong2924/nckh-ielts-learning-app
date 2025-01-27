import 'package:flutter/material.dart';

class FillInTheBlankQuestion extends StatelessWidget {
  final String questionText;
  final Function(String?) onAnswerSubmitted;

  FillInTheBlankQuestion({
    required this.questionText,
    required this.onAnswerSubmitted, required initialAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your answer',
            ),
            onSubmitted: (value) => onAnswerSubmitted(value),
          ),
        ],
      ),
    );
  }
}
