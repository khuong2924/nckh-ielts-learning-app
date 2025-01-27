import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/presentation/components/FillInTheBlank.dart';

class ListeningTestPage extends StatefulWidget {
  final int testId;

  const ListeningTestPage({Key? key, required this.testId}) : super(key: key);

  @override
  State<ListeningTestPage> createState() => _ListeningTestPageState();
}

class _ListeningTestPageState extends State<ListeningTestPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late String userId;
  List<Map<String, dynamic>> parts = [];
  Map<int, List<Map<String, dynamic>>> partAnswers = {};
  Map<int, Map<int, String>> userAnswers = {}; // User's answers
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
        userAnswers[part['id']] ??= {}; // Initialize user answers for each part
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

  double _calculateIELTSScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0.0; // Tránh chia cho 0
    double score = (correctAnswers / totalQuestions) * 9; // Tính thang điểm 9
    return score.clamp(0, 9); // Đảm bảo điểm nằm trong khoảng 0-9
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

      // Iterate through each part and compare user answers with correct answers
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

      // Tính điểm IELTS
      final score = _calculateIELTSScore(correctAnswers, totalQuestions);

      // Prepare answers for submission
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

      // Save answers to database
      await Supabase.instance.client.from('user_answers').upsert(answersToSubmit);

      // Save test results to database
      await Supabase.instance.client.from('test_results').insert({
        'user_id': userId,
        'test_id': widget.testId,
        'score': score,
        'total_questions': totalQuestions,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test submitted! Your IELTS score is ${score.toStringAsFixed(2)}.')),
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
      appBar: AppBar(title: const Text('Listening Test')),
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
            audioPlayer: _audioPlayer,
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
  final AudioPlayer audioPlayer;
  final Map<int, String> userAnswers;
  final Function(int, String) onAnswerChanged;

  const PartWidget({
    Key? key,
    required this.part,
    required this.answers,
    required this.audioPlayer,
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
            if (part['audio_url'] != null)
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.green),
                onPressed: () async {
                  await audioPlayer.play(part['audio_url']);
                },
              ),
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
