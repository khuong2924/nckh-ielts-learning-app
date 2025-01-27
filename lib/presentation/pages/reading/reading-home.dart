import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/presentation/components/FillInTheBlank.dart';

class ReadingHome extends StatefulWidget {
  final int testId;

  const ReadingHome({Key? key, required this.testId}) : super(key: key);

  @override
  State<ReadingHome> createState() => _ReadingHomeState();
}

class _ReadingHomeState extends State<ReadingHome> {
  late String userId;
  List<Map<String, dynamic>> parts = [];
  Map<int, List<Map<String, dynamic>>> partAnswers = {};
  Map<int, Map<int, String>> userAnswers = {}; // Câu trả lời của người dùng
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('user_id') ?? '';

      final partsResponse = await Supabase.instance.client
          .from('listening_parts')
          .select()
          .eq('test_id', widget.testId)
          .order('id', ascending: true);

      final List<Map<String, dynamic>> partsData = List<Map<String, dynamic>>.from(partsResponse as List);

      for (var part in partsData) {
        final answersResponse = await Supabase.instance.client
            .from('answers')
            .select()
            .eq('part_id', part['id'])
            .order('question_number', ascending: true);

        partAnswers[part['id']] = List<Map<String, dynamic>>.from(answersResponse as List);
        userAnswers[part['id']] ??= {}; // Khởi tạo câu trả lời người dùng cho mỗi phần
      }

      setState(() {
        parts = partsData;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _submitAnswers() async {
    if (userAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    try {
      int correctAnswers = 0;
      int totalQuestions = 0;

      // So sánh câu trả lời người dùng với đáp án đúng
      for (var entry in userAnswers.entries) {
        final partId = entry.key; // ID của phần
        final partUserAnswers = entry.value; // Đáp án của người dùng cho phần này

        for (var questionEntry in partUserAnswers.entries) {
          final questionNumber = questionEntry.key; // Số thứ tự câu hỏi
          final userAnswer = questionEntry.value.trim().toLowerCase(); // Đáp án người dùng

          // Tìm đáp án đúng từ partAnswers
          final correctAnswer = partAnswers[partId]?.firstWhere(
                  (answer) => answer['question_number'] == questionNumber,
              orElse: () => {'correct_answer': null})['correct_answer']?.toString().toLowerCase();

          if (correctAnswer != null) {
            totalQuestions++;
            if (userAnswer == correctAnswer) {
              correctAnswers++;
            }
          }
        }
      }

      // Lưu câu trả lời vào cơ sở dữ liệu
      final List<Map<String, dynamic>> answersToSubmit = userAnswers.entries
          .expand((entry) => entry.value.entries.map((answerEntry) {
        final questionNumber = answerEntry.key;
        final userAnswer = answerEntry.value;
        final correctAnswer = partAnswers[entry.key]?.firstWhere(
                (answer) => answer['question_number'] == questionNumber)['correct_answer'];

        return {
          'user_id': userId,
          'part_id': entry.key,
          'question_number': questionNumber,
          'user_answer': userAnswer,
          'is_correct': userAnswer.trim().toLowerCase() == correctAnswer?.toString().toLowerCase(),
        };
      }))
          .toList();

      // Lưu câu trả lời vào cơ sở dữ liệu
      await Supabase.instance.client.from('user_answers').upsert(answersToSubmit);

      // Lưu kết quả bài thi vào cơ sở dữ liệu
      await Supabase.instance.client.from('test_results').insert({
        'user_id': userId,
        'test_id': widget.testId,
        'score': (correctAnswers / totalQuestions) * 9, // Tính điểm IELTS
        'total_questions': totalQuestions,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test submitted! Your score is ${(correctAnswers / totalQuestions * 9).toStringAsFixed(2)}.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answers: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Test')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: parts.length,
        itemBuilder: (context, index) {
          final part = parts[index];
          final answers = partAnswers[part['id']] ?? [];

          return PartWidget(
            part: part,
            answers: answers,
            userAnswers: userAnswers[part['id']] ?? {},
            onAnswerChanged: (questionNumber, answer) {
              setState(() {
                userAnswers[part['id']] ??= {};
                userAnswers[part['id']]![questionNumber] = answer;
              });
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _submitAnswers,
          child: const Text('Submit Answers'),
        ),
      ),
    );
  }
}

class PartWidget extends StatelessWidget {
  final Map<String, dynamic> part;
  final List<Map<String, dynamic>> answers;
  final Map<int, String> userAnswers;
  final Function(int, String) onAnswerChanged;

  const PartWidget({
    Key? key,
    required this.part,
    required this.answers,
    required this.userAnswers,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                return FillInTheBlankQuestion(
                  questionText: 'Question ${answer['question_number']}',
                  initialAnswer: userAnswers[answer['question_number']] ?? '',
                  onAnswerSubmitted: (userAnswer) {
                    onAnswerChanged(answer['question_number'], userAnswer ?? '');
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}