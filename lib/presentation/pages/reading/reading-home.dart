import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../route_persistence.dart';
import 'reading-done.dart';

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
  Map<int, Map<int, String>> userAnswers = {}; // [partId][questionNumber] = user_answer
  bool isLoading = true;

  int totalTime = 60 * 60; // 60 phút
  int remainingTime = 60 * 60;
  Timer? _timer;

  Map<int, int> correctAnswersPerPart = {};

  @override
  void initState() {
    super.initState();
    saveLastRoute(
      'reading_home',
      {'testId': widget.testId.toString()},
    );
    _initAll();
    _startTimer();
  }


  Future<void> _initAll() async {
    await _restoreProgressFromLocal();
    await _loadData();
  }

  Future<void> _saveTestProgressToLocal() async {
    final box = await Hive.openBox('reading_progress');
    await box.put(
      'progress_${widget.testId}',
      {
        'userAnswers': userAnswers,
        'remainingTime': remainingTime,
      },
    );
  }

  Future<void> _restoreProgressFromLocal() async {
    final box = await Hive.openBox('reading_progress');
    final data = box.get('progress_${widget.testId}');
    if (data != null) {
      final Map<String, dynamic> answers = Map<String, dynamic>.from(data['userAnswers'] ?? {});
      userAnswers = answers.map(
            (k, v) => MapEntry(
          int.parse(k),
          Map<int, String>.from(
            (v as Map).map(
                  (qk, qv) => MapEntry(int.parse(qk.toString()), qv.toString()),
            ),
          ),
        ),
      );
      remainingTime = data['remainingTime'] ?? totalTime;
    }
  }


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        _timer?.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    _submitAnswers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time is up! Your answers have been submitted automatically.')),
    );
  }

  Future<void> _saveUserAnswersToLocal() async {
    final box = await Hive.openBox('reading_progress');
    await box.put(
      'user_answers_${widget.testId}',
      userAnswers,
    );
  }
  Future<void> _restoreUserAnswersFromLocal() async {
    final box = await Hive.openBox('reading_progress');
    final data = box.get('user_answers_${widget.testId}');
    if (data != null) {
      final decoded = Map<String, dynamic>.from(data);
      userAnswers = decoded.map(
            (k, v) => MapEntry(
          int.parse(k),
          Map<int, String>.from(
            (v as Map).map((qk, qv) => MapEntry(int.parse(qk.toString()), qv.toString())),
          ),
        ),
      );
    }
  }


  Future<void> _loadData() async {
    try {
      final box = await Hive.openBox('user_info');
      userId = box.get('user_id', defaultValue: '');

      final partsResponse = await Supabase.instance.client
          .from('listening_parts') // Nếu dùng reading_parts thì đổi lại ở đây!
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
        userAnswers[part['id']] ??= {};
      }

      await _restoreUserAnswersFromLocal();

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
      int totalCorrect = 0;
      int totalQuestions = 0;
      Map<int, int> correctCountByPart = {};

      for (var entry in userAnswers.entries) {
        final partId = entry.key;
        final partUserAnswers = entry.value;
        int correctCount = 0;

        for (var questionEntry in partUserAnswers.entries) {
          final questionNumber = questionEntry.key;
          final userAnswer = questionEntry.value.trim().toLowerCase();

          final correctAnswer = partAnswers[partId]?.firstWhere(
                  (answer) => answer['question_number'] == questionNumber,
              orElse: () => {'correct_answer': null})['correct_answer']?.toString().toLowerCase();

          if (correctAnswer != null) {
            totalQuestions++;
            if (userAnswer == correctAnswer) {
              correctCount++;
              totalCorrect++;
            }

            // Lưu câu trả lời của người dùng vào user_answers
            await Supabase.instance.client.from('user_answers').insert({
              'user_id': userId,
              'part_id': partId,
              'question_number': questionNumber,
              'user_answer': userAnswer,
              'is_correct': userAnswer == correctAnswer,
            });
          }
        }
        correctCountByPart[partId] = correctCount;
      }

      setState(() {
        correctAnswersPerPart = correctCountByPart;
      });

      final score = _calculateIELTSScore(totalCorrect, totalQuestions);

      // Lưu kết quả test vào test_results
      await Supabase.instance.client.from('test_results').insert({
        'user_id': userId,
        'test_id': widget.testId,
        'score': score.toInt(),
        'total_questions': totalQuestions,
        'time': totalTime - remainingTime, // thời gian làm bài
        'part1': correctCountByPart[1]?.toString() ?? '0',
        'part2': correctCountByPart[2]?.toString() ?? '0',
        'part3': correctCountByPart[3]?.toString() ?? '0',
      });

      // Xoá dữ liệu local sau khi nộp bài
      final box = await Hive.openBox('reading_progress');
      await box.delete('user_answers_${widget.testId}');
      await box.delete('progress_${widget.testId}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test submitted! Your IELTS score is ${score.toStringAsFixed(2)}.')),
      );

      _timer?.cancel();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReadingDone(
            score: score,
            timeTaken: totalTime - remainingTime,
            correctAnswersPerPart: correctCountByPart,
            userAnswers: userAnswers,
            parts: parts,
            partAnswers: partAnswers,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answers: ${e.toString()}')),
      );
    }
  }

  double _calculateIELTSScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    double score = (correctAnswers / totalQuestions) * 9;
    return score.clamp(0, 9);
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirmExit = await _showExitConfirmation();
        return confirmExit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reading Test')),
        body: Stack(
          children: [
            isLoading
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
                      userAnswers.putIfAbsent(part['id'], () => {});
                      userAnswers[part['id']]![questionNumber] = answer;
                    });
                    _saveUserAnswersToLocal();        // Cũ: chỉ lưu đáp án
                    _saveTestProgressToLocal();       // Mới: lưu cả đáp án + thời gian
                  },

                );
              },
            ),
            // Countdown timer góc phải trên
            Positioned(
              top: 10,
              right: 10,
              child: Chip(
                label: Text('Time left: ${_formatTime(remainingTime)}',
                    style: TextStyle(fontSize: 16)),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: _submitAnswers,
            child: const Text('Submit Answers'),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text('Are you sure you want to exit? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }
}

// ========== PartWidget + FillInTheBlankQuestion ==========

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
              part['part_title'] ?? '',
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
                    onAnswerChanged(answer['question_number'], userAnswer?.trim() ?? '');
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

class FillInTheBlankQuestion extends StatefulWidget {
  final String questionText;
  final String initialAnswer;
  final ValueChanged<String>? onAnswerSubmitted;

  const FillInTheBlankQuestion({
    Key? key,
    required this.questionText,
    required this.initialAnswer,
    this.onAnswerSubmitted,
  }) : super(key: key);

  @override
  State<FillInTheBlankQuestion> createState() => _FillInTheBlankQuestionState();
}

class _FillInTheBlankQuestionState extends State<FillInTheBlankQuestion> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer);
    _controller.addListener(() {
      widget.onAnswerSubmitted?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: null,
          ),
        ],
      ),
    );
  }
}
