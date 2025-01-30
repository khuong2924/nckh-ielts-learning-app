import 'package:flutter/material.dart';

class FillInTheBlankQuestion extends StatefulWidget {
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
  _FillInTheBlankQuestionState createState() => _FillInTheBlankQuestionState();
}

class _FillInTheBlankQuestionState extends State<FillInTheBlankQuestion> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng tài nguyên
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.questionText, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          TextField(
            controller: _controller,
            onChanged: (value) {
              widget.onAnswerSubmitted(value); // Trả về câu trả lời
            },
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