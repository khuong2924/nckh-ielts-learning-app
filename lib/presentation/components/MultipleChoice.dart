import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatelessWidget {
  final String questionText;
  final List<String> choices;
  final Function(String?) onAnswerSelected;
  final String? selectedAnswer;

  MultipleChoiceQuestion({
    required this.questionText,
    required this.choices,
    required this.onAnswerSelected,
    this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...choices.map((choice) {
          return RadioListTile<String>(
            title: Text(choice),
            value: choice,
            groupValue: selectedAnswer,
            onChanged: (value) {
              if (onAnswerSelected != null) {
                onAnswerSelected(value); // Callback to parent
              }
            },
          );
        }).toList(),
      ],
    );
  }
}
