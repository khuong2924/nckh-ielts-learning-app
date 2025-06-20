import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../route_persistence.dart';
import 'reading-done.dart';
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
  Map<int, Map<int, String>> userAnswers = {};
  bool isLoading = true;

  int totalTime = 60 * 60;
  int remainingTime = 60 * 60;
  Timer? _timer;

  Map<int, int> correctAnswersPerPart = {};
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    saveLastRoute('reading_home', {'testId': widget.testId.toString()});
    _loadThemePref();
    _initAll();
    _startTimer();
  }

  // ==== Theme prefs ====
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

  Future<void> _initAll() async {
    await _restoreProgressFromLocal();
    await _loadData();
  }

  Future<void> _saveTestProgressToLocal() async {
    final box = await Hive.openBox('reading_progress');
    await box.put(
      'progress_${widget.testId}',
      {'userAnswers': userAnswers, 'remainingTime': remainingTime},
    );
  }

  Future<void> _restoreProgressFromLocal() async {
    final box = await Hive.openBox('reading_progress');
    final raw = box.get('progress_${widget.testId}');
    if (raw is Map) {
      // 1) cast phần userAnswers
      final uaRaw = Map<dynamic,dynamic>.from(raw['userAnswers'] ?? {});
      userAnswers = uaRaw.map((partKey, qaMap) {
        final pid = int.parse(partKey.toString());
        final qa = Map<dynamic,dynamic>.from(qaMap);
        final qMap = qa.map((qk, qv) =>
            MapEntry(int.parse(qk.toString()), qv.toString())
        );
        return MapEntry(pid, qMap);
      });
      // 2) remainingTime
      remainingTime = raw['remainingTime'] as int? ?? totalTime;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
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
    await box.put('user_answers_${widget.testId}', userAnswers);
  }

  Future<void> _restoreUserAnswersFromLocal() async {
    final box = await Hive.openBox('reading_progress');
    final data = box.get('user_answers_${widget.testId}');
    if (data != null) {
      final decoded = Map<String, dynamic>.from(data);
      userAnswers = decoded.map(
            (k, v) => MapEntry(
          int.parse(k),
          Map<int, String>.from((v as Map).map((qk, qv) => MapEntry(int.parse(qk.toString()), qv.toString()))),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      // 1) Lấy userId từ Hive
      final userBox = await Hive.openBox('app_box');
      userId = userBox.get('user_id', defaultValue: '');

      // 2) Load các part cho test này
      final partsResp = await Supabase.instance.client
          .from('listening_parts')
          .select()
          .eq('test_id', widget.testId)
          .order('id', ascending: true);

      if (partsResp is List) {
        parts = partsResp.cast<Map<String, dynamic>>();
      } else {
        parts = [];
      }

      // 3) Với mỗi part, load luôn answers và tạo map chứa userAnswers trống
      for (final p in parts) {
        final pid = p['id'] as int;

        // Load đáp án đúng
        final ansResp = await Supabase.instance.client
            .from('answers')
            .select()
            .eq('part_id', pid)
            .order('question_number', ascending: true);

        if (ansResp is List) {
          partAnswers[pid] = ansResp.cast<Map<String, dynamic>>();
        } else {
          partAnswers[pid] = [];
        }

        // Khởi tạo entry cho userAnswers nếu chưa có
        userAnswers.putIfAbsent(pid, () => <int, String>{});
      }

      // 4) Khôi phục câu trả lời đã lưu local (nếu có)
      await _restoreUserAnswersFromLocal();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _submitAnswers() async {
    // 1) Đảm bảo đã trả lời hết các câu
    final expectedQuestions = partAnswers.values.fold<int>(
      0,
          (sum, list) => sum + list.length,
    );
    final providedAnswers = userAnswers.values.fold<int>(
      0,
          (sum, m) => sum + m.length,
    );
    if (providedAnswers < expectedQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    try {
      // 2) Tính số câu đúng
      int totalCorrect = 0;
      final correctByPart = <int, int>{};

      // Chuẩn bị dữ liệu để insert/update user_answers
      final answersUpsert = <Map<String, dynamic>>[];

      for (final entry in userAnswers.entries) {
        final partId = entry.key;
        int partCorrect = 0;
        final correctList = partAnswers[partId] ?? [];

        for (final qa in entry.value.entries) {
          final qNo = qa.key;
          final ua  = qa.value.trim().toLowerCase();
          final matched = correctList.firstWhere(
                (a) => a['question_number'] == qNo,
            orElse: () => <String, dynamic>{},
          );
          final ca = matched['correct_answer']?.toString().toLowerCase();

          if (ca != null) {
            final isCorrect = ua == ca;
            if (isCorrect) {
              totalCorrect++;
              partCorrect++;
            }
            answersUpsert.add({
              'user_id'        : userId,
              'part_id'        : partId,
              'question_number': qNo,
              'user_answer'    : ua,
              'is_correct'     : isCorrect,
            });
          }
        }

        correctByPart[partId] = partCorrect;
      }

      // 3) Manual upsert vào user_answers
      for (final rec in answersUpsert) {
        final partId = rec['part_id'] as int;
        final qNo    = rec['question_number'] as int;

        final existing = await Supabase.instance.client
            .from('user_answers')
            .select()
            .eq('user_id',        rec['user_id'])
            .eq('part_id',        partId)
            .eq('question_number', qNo);

        if (existing is List && existing.isNotEmpty) {
          await Supabase.instance.client
              .from('user_answers')
              .update({
            'user_answer': rec['user_answer'],
            'is_correct' : rec['is_correct'],
          })
              .eq('user_id',        rec['user_id'])
              .eq('part_id',        partId)
              .eq('question_number', qNo);
        } else {
          await Supabase.instance.client
              .from('user_answers')
              .insert([rec]);
        }
      }

      // 4) Tính điểm IELTS (thang 9)
      final rawScore = expectedQuestions > 0
          ? (totalCorrect / expectedQuestions) * 9
          : 0.0;
      final score = rawScore.clamp(0, 9).toInt();

      // 5) Chuẩn bị record cho test_results
      final resultRecord = {
        'user_id'        : userId,
        'test_id'        : widget.testId,
        'score'          : score,
        'total_questions': expectedQuestions,
        'time'           : totalTime - remainingTime,
        // Ví dụ lưu đúng theo part:
        if (parts.isNotEmpty) 'part1': correctByPart[parts[0]['id']]?.toString() ?? '0',
        if (parts.length > 1) 'part2': correctByPart[parts[1]['id']]?.toString() ?? '0',
        if (parts.length > 2) 'part3': correctByPart[parts[2]['id']]?.toString() ?? '0',
      };

      // 6) Manual upsert vào test_results
      final existingResult = await Supabase.instance.client
          .from('test_results')
          .select()
          .eq('user_id', userId)
          .eq('test_id', widget.testId);

      if (existingResult is List && existingResult.isNotEmpty) {
        await Supabase.instance.client
            .from('test_results')
            .update(resultRecord)
            .eq('user_id', userId)
            .eq('test_id', widget.testId);
      } else {
        await Supabase.instance.client
            .from('test_results')
            .insert([resultRecord]);
      }

      // 7) Xóa cache local
      final box = await Hive.openBox('reading_progress');
      await box.delete('user_answers_${widget.testId}');
      await box.delete('progress_${widget.testId}');

      // 8) Thông báo & điều hướng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test submitted! Your IELTS score: $score')),
      );
      _timer?.cancel();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingDone(
            score: score.toDouble(),
            timeTaken: totalTime - remainingTime,
            correctAnswersPerPart: correctByPart,
            userAnswers: userAnswers,
            parts: parts,
            partAnswers: partAnswers,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    }
  }


  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2,'0');
    final s = (sec % 60).toString().padLeft(2,'0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _showExitConfirmation(),
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
            title: const Text('Reading Test'),
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
                    return PartWidget(
                      part: parts[idx],
                      answers: partAnswers[parts[idx]['id']]!,
                      userAnswers: userAnswers[parts[idx]['id']]!,
                      onAnswerChanged: (qNo, ans) {
                        setState(() {
                          userAnswers.putIfAbsent(parts[idx]['id'], () => {});
                          userAnswers[parts[idx]['id']]![qNo] = ans;
                        });
                        _saveUserAnswersToLocal();
                        _saveTestProgressToLocal();
                      },
                    );
                  },
                ),
              Positioned(
                top: 10, right: 10,
                child: Chip(
                  label: Text('Time left: ${_formatTime(remainingTime)}',
                      style: const TextStyle(fontSize: 16)),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
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

}

class PartWidget extends StatelessWidget {
  final Map<String, dynamic> part;
  final List<Map<String, dynamic>> answers;
  final Map<int, String> userAnswers;
  final void Function(int, String) onAnswerChanged;

  const PartWidget({
    Key? key,
    required this.part,
    required this.answers,
    required this.userAnswers,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // thay "\n" thành newline thật
    final rawDesc = part['part_description']?.toString() ?? '';
    final formattedDesc = rawDesc.replaceAll(r'\n', '\n');

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              part['part_title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(formattedDesc),
            const SizedBox(height: 10),
            ...answers.map((ans) => FillInTheBlankQuestion(
              questionText: 'Question ${ans['question_number']}',
              initialAnswer: userAnswers[ans['question_number']] ?? '',
              onAnswerSubmitted: (val) {
                final cleaned = (val ?? '').trim();
                onAnswerChanged(ans['question_number'], cleaned);
              },
            )),
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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer)
      ..addListener(() {
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
      padding: const EdgeInsets.symmetric(vertical:8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
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
