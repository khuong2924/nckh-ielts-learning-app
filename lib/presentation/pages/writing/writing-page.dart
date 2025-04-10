import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'writing-submission.dart'; // <-- Đừng quên đổi tên đúng nếu bạn lưu tên khác

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
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadUserId();
    await _fetchParts();
    _startTimer();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
  }

  Future<void> _fetchParts() async {
    try {
      final response = await Supabase.instance.client
          .from('listening_parts')
          .select()
          .eq('test_id', widget.testId)
          .order('id', ascending: true);

      setState(() {
        parts = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      if (parts.length != 2) {
        _showSnackBar('Error: The test must have exactly two tasks.');
      }
    } catch (e) {
      _showSnackBar('Error loading data: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => elapsedTime++);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitAnswers() async {
    if (userAnswers.length < 2) {
      _showSnackBar('Please complete both tasks before submitting.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';

      for (var part in parts) {
        final partId = part['id'];
        final answer = userAnswers[partId]?.trim() ?? '';

        // Chỉ lưu nếu có dữ liệu
        if (answer.isNotEmpty) {
          await Supabase.instance.client.from('user_answers').insert({
            'user_id': userId,
            'part_id': partId,
            'question_number': 1, // Vì mỗi part của writing chỉ có 1 câu
            'user_answer': answer,
            'is_correct': null, // Không áp dụng với writing
          });
        }
      }

      // Chuyển sang màn hình phản hồi
      final submissions = parts.map((part) {
        return {
          "task_description": (part['part_description'] ?? '').toString(),
          "user_answer": (userAnswers[part['id']] ?? '').toString(),
        };
      }).toList();

      _timer?.cancel();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IeltsFeedbackPage(
            submissions: submissions,
            elapsedTime: elapsedTime,
            testId: widget.testId, // ✅ truyền đúng testId gốc
          ),
        ),
      );

    } catch (e) {
      _showSnackBar("Error saving answers: ${e.toString()}");
    }
  }



  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text('Are you sure you want to exit? Your progress will not be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.of(context).pop(true);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmation,
      child: Scaffold(
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
                    setState(() => userAnswers[part['id']] = answer);
                  },
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Chip(
                label: Text('Time: ${_formatTime(elapsedTime)}', style: const TextStyle(fontSize: 16)),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(onPressed: _submitAnswers, child: const Text('Submit Answers')),
        ),
      ),
    );
  }
}

class PartWidget extends StatefulWidget {
  final Map<String, dynamic> part;
  final String userAnswer;
  final Function(String) onAnswerChanged;

  const PartWidget({Key? key, required this.part, required this.userAnswer, required this.onAnswerChanged})
      : super(key: key);

  @override
  _PartWidgetState createState() => _PartWidgetState();
}

class _PartWidgetState extends State<PartWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              widget.part['part_title'] ?? 'Untitled Task',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if ((widget.part['image_url'] ?? '').toString().isNotEmpty)
              Image.network(widget.part['image_url'], height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(widget.part['part_description'] ?? 'No description available.'),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              onChanged: widget.onAnswerChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}
