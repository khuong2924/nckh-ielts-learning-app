import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/presentation/pages/writing/writing-submission.dart';

class WritingPage extends StatefulWidget {
  final int testId;
  const WritingPage({Key? key, required this.testId}) : super(key: key);

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  late String userId;
  List<Map<String, dynamic>> parts = [];
  Map<int, String> userAnswers = {};
  bool isLoading = true;
  int elapsedTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime++;
      });
    });
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

      setState(() {
        parts = List<Map<String, dynamic>>.from(partsResponse as List);
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

    String essayText = userAnswers.values.join("\n\n"); // Gộp toàn bộ bài viết

    // Chuyển sang trang chấm bài WritingResultPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IeltsFeedbackPage(userInput: essayText),
      ),
    );
  }


  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Writing Test')),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: parts.length,
            itemBuilder: (context, index) {
              final part = parts[index];
              return PartWidget(
                part: part,
                userAnswer: userAnswers[part['id']] ?? '',
                onAnswerChanged: (answer) {
                  setState(() {
                    userAnswers[part['id']] = answer;
                  });
                },
              );
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Chip(
              label: Text('Time: ${_formatTime(elapsedTime)}', style: TextStyle(fontSize: 16)),
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
    );
  }
}

class PartWidget extends StatelessWidget {
  final Map<String, dynamic> part;
  final String userAnswer;
  final Function(String) onAnswerChanged;

  const PartWidget({
    Key? key,
    required this.part,
    required this.userAnswer,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String partTitle = part['part_title'] ?? 'Untitled Part';
    String partDescription = part['part_description'] ?? 'No description';
    String? imageUrl = part['image_url'];

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              partTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(imageUrl, height: 200, fit: BoxFit.cover),

            const SizedBox(height: 10),
            Text(partDescription),

            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Answer:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  onChanged: onAnswerChanged,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}