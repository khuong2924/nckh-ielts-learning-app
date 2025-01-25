import 'package:flutter/material.dart';

class FillInTheBlankQuestion extends StatelessWidget {
  final String questionText;
  final Function(String?) onAnswerSubmitted;

  FillInTheBlankQuestion({
    required this.questionText,
    required this.onAnswerSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your answer',
          ),
          onSubmitted: (value) {
            if (onAnswerSubmitted != null) {
              onAnswerSubmitted(value); // Callback to parent
            }
          },
        ),
      ],
    );
  }
}
