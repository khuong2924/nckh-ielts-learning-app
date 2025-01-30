import 'package:flutter/material.dart';
class ViewAnswersPage extends StatelessWidget {
  final List<Map<String, dynamic>> parts; // List of parts (questions)
  final Map<int, String> userAnswers; // User's answers
  final Map<int, List<Map<String, dynamic>>> partAnswers; // Correct answers

  const ViewAnswersPage({
    Key? key,
    required this.parts,
    required this.userAnswers,
    required this.partAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Answers')),
      body: ListView.builder(
        itemCount: parts.length,
        itemBuilder: (context, index) {
          final part = parts[index];
          final answers = partAnswers[part['id']] ?? [];

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part['part_title'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(part['part_description'] ?? 'No description'),
                  const SizedBox(height: 10),
                  Column(
                    children: answers.map((answer) {
                      final questionNumber = answer['question_number'];
                      final userAnswer = userAnswers[questionNumber] ?? 'No answer';
                      final correctAnswer = answer['correct_answer'] ?? 'No correct answer';

                      return ListTile(
                        title: Text('Question $questionNumber'),
                        subtitle: Text('Your Answer: $userAnswer\nCorrect Answer: $correctAnswer'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}