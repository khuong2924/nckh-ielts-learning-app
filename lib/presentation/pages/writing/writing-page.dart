import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'writing-submission.dart'; // Đổi thành import của bạn nếu khác

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
  int totalTime     = 60 * 10*6;   // ví dụ 10 phút = 600s
  int remainingTime = 60 * 10*6;
  Timer? _timer;

  // ==== Theme state ====
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePref();
    _initializePage();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        _timer?.cancel();
        _autoSubmit();    // tùy bạn có muốn tự động nộp khi hết giờ
      }
    });
  }
  void _autoSubmit() {
    _submitAnswers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time is up! Your answers have been submitted automatically.')),
    );
  }

  Future<void> _loadThemePref() async {
    final box = await Hive.openBox('settings');
    setState(() {
      isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;
    });
  }

  Future<void> _toggleTheme() async {
    setState(() => isDarkMode = !isDarkMode);
    final box = await Hive.openBox('settings');
    await box.put('isDarkMode', isDarkMode);
  }
  // ====================

  Future<void> _initializePage() async {
    await _loadUserId();
    await _fetchParts();
    _startCountdown();
  }

  Future<void> _loadUserId() async {
    final box = await Hive.openBox('app_box');
    userId = box.get('user_id', defaultValue: '');
  }

  Future<void> _fetchParts() async {
    try {
      final resp = await Supabase.instance.client
          .from('listening_parts')
          .select()
          .eq('test_id', widget.testId)
          .order('id', ascending: true);
      parts = List<Map<String,dynamic>>.from(resp as List);
      setState(() => isLoading = false);

      if (parts.length != 2) {
        _showSnackBar('Error: The test must have exactly two tasks.');
      }
    } catch (e) {
      _showSnackBar('Error loading data: $e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitAnswers() async {
    // 1) Đảm bảo đã load userId
    if (userId.isEmpty) {
      _showSnackBar('Please log in first.');
      return;
    }

    // 2) Đảm bảo đã điền đủ 2 phần
    if (userAnswers.length < parts.length) {
      _showSnackBar('Please complete both tasks before submitting.');
      return;
    }

    try {
      // 3) Tạo list submissions để chuyển sang Feedback
      final submissions = <Map<String, String>>[];

      // 4) Chuẩn bị upsert cho user_answers
      for (final part in parts) {
        final pid    = part['id'] as int;
        final answer = (userAnswers[pid]?.trim() ?? '');

        // Gom submissions
        final rawDesc     = part['part_description']?.toString() ?? '';
        final formattedDesc = rawDesc.replaceAll(r'\n', '\n');
        submissions.add({
          'task_description': formattedDesc,
          'user_answer'     : answer,
        });

        // Nếu answer không rỗng thì upsert
        if (answer.isNotEmpty) {
          // Kiểm tra xem đã có record chưa
          final exists = await Supabase.instance.client
              .from('user_answers')
              .select()
              .eq('user_id', userId)
              .eq('part_id', pid)
              .eq('question_number', 1);

          if (exists is List && exists.isNotEmpty) {
            // update
            await Supabase.instance.client
                .from('user_answers')
                .update({
              'user_answer': answer,
              'is_correct' : null,
            })
                .eq('user_id', userId)
                .eq('part_id', pid)
                .eq('question_number', 1);
          } else {
            // insert
            await Supabase.instance.client
                .from('user_answers')
                .insert([{
              'user_id'        : userId,
              'part_id'        : pid,
              'question_number': 1,
              'user_answer'    : answer,
              'is_correct'     : null,
            }]);
          }
        }
      }

      // 5) Dừng timer và chuyển màn sang feedback
      _timer?.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IeltsFeedbackPage(
            submissions: submissions,
            elapsedTime: (totalTime-remainingTime),
            testId: widget.testId,
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Error saving answers: $e');
    }
  }


  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2,'0');
    final s = (seconds % 60).toString().padLeft(2,'0');
    return '$m:$s';
  }


  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: const [
            Icon(Icons.exit_to_app, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Exit Test?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit? Your progress will not be saved.',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _timer?.cancel();
              Navigator.of(context).pop(true);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmation,
      child: Theme(
        data: isDarkMode
            ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.blue)
            : ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.blue),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Writing Test'),
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleTheme,
              ),
            ],
          ),
          body: Stack(
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  itemCount: parts.length,
                  itemBuilder: (_, idx) {
                    final part = parts[idx];
                    return PartWidget(
                      part: part,
                      userAnswer: userAnswers[part['id']] ?? '',
                      onAnswerChanged: (txt) {
                        setState(() => userAnswers[part['id']] = txt);
                      },
                    );
                  },
                ),
              Positioned(
                top: 10, right: 10,
                child: Chip(
                  label: Text(
                    'Time left: ${_formatTime(remainingTime)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: _submitAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Submit Answers'),
              ),
            ),
          ),
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
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userAnswer);
    _wordCount = _countWords(_controller.text);
    _controller.addListener(() {
      setState(() {
        _wordCount = _countWords(_controller.text);
      });
      widget.onAnswerChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
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
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 8,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Word count: $_wordCount', style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}