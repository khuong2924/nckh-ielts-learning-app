import 'package:flutter/material.dart';

class ViewAnswersPage extends StatelessWidget {
  final List<Map<String, dynamic>> parts; // Danh sách các phần
  final Map<int, Map<int, String>> userAnswersPerPart; // Đáp án người dùng theo từng phần
  final Map<int, List<Map<String, dynamic>>> partAnswers; // Đáp án đúng theo từng phần

  const ViewAnswersPage({
    Key? key,
    required this.parts,
    required this.userAnswersPerPart,
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
          final partId = part['id'];
          final answers = partAnswers[partId] ?? []; // Đáp án đúng của phần này
          final userAnswers = userAnswersPerPart[partId] ?? {}; // Đáp án của user cho phần này

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
                  if (answers.isNotEmpty)
                    Column(
                      children: answers.map((answer) {
                        final questionNumber = answer['question_number'];
                        final userAnswer = userAnswers[questionNumber] ?? 'No answer';
                        final correctAnswer = answer['correct_answer'] ?? 'No correct answer';

                        return ListTile(
                          title: Text('Question $questionNumber'),
                          subtitle: Text(
                            'Your Answer: $userAnswer\nCorrect Answer: $correctAnswer',
                            style: TextStyle(
                              color: userAnswer == correctAnswer ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text('No answers available for this part.'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
