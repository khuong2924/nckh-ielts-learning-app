import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth/presentation/pages/reading/reading-done.dart';
import 'package:auth/presentation/components/FillInTheBlank.dart';

import '../../route_persistence.dart';

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
  Map<int, Map<int, String>> userAnswers = {};
  Map<int, int> correctAnswersPerPart = {};
  bool isLoading = true;
  int totalTime     = 60 * 10*6;   // ví dụ 10 phút = 600s
  int remainingTime = 60 * 10*6;
  Timer? _timer;

  // ==== Theme state ====
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    saveLastRoute("listening_test", {"testId": widget.testId.toString()});
    _loadThemePref().then((_) {
      _restoreProgressIfAny().then((_) async {
        await _loadData();
        _startCountdown();
      });
    });
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
  // ========== Theme preferences ==========
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
  // ========================================

  void _onAnswerChanged(int partId, int questionNumber, String answer) {
    setState(() {
      userAnswers[partId] ??= {};
      userAnswers[partId]![questionNumber] = answer;
    });
    _saveCurrentProgress();
  }

  /// Ghi tạm tiến trình vào Hive, gồm remainingTime và userAnswers
  Future<void> _saveCurrentProgress() async {
    final box = await Hive.openBox('progress');
    final saveData = {
      'remainingTime': remainingTime,
      'userAnswers'  : userAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'testId'       : widget.testId,
    };
    await box.put(
      'listening_test_in_progress_${widget.testId}',
      jsonEncode(saveData),
    );
  }

  /// Restore lại tiến trình từ Hive, thiết lập remainingTime và userAnswers
  Future<void> _restoreProgressIfAny() async {
    final box   = await Hive.openBox('progress');
    final saved = box.get('listening_test_in_progress_${widget.testId}');
    if (saved != null) {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      if (data['testId'] == widget.testId) {
        // 1) Đặt lại remainingTime (mặc định là totalTime nếu key không tồn tại)
        remainingTime = data['remainingTime'] as int? ?? totalTime;
        // 2) Đọc lại userAnswers
        final rawMap = Map<String, dynamic>.from(data['userAnswers'] ?? {});
        userAnswers = rawMap.map((partKey, qaMap) {
          final pid = int.parse(partKey);
          final inner = Map<String, dynamic>.from(qaMap);
          final qaTyped = inner.map((qk, qv) =>
              MapEntry(int.parse(qk), qv.toString())
          );
          return MapEntry(pid, qaTyped);
        });
      }
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<void> _loadData() async {
    try {
      final box = await Hive.openBox('app_box');
      userId = box.get('user_id', defaultValue: '');

      final partsResponse = await Supabase.instance.client
          .from('listening_parts')
          .select()
          .eq('test_id', widget.testId)
          .order('id', ascending: true);

      parts = List<Map<String, dynamic>>.from(partsResponse as List);
      for (var part in parts) {
        final answersResponse = await Supabase.instance.client
            .from('answers')
            .select()
            .eq('part_id', part['id'])
            .order('question_number', ascending: true);
        partAnswers[part['id']] = List<Map<String, dynamic>>.from(answersResponse as List);
        userAnswers[part['id']] ??= {};
      }

      setState(() => isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  double _calculateIELTSScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    return ((correctAnswers / totalQuestions) * 9).clamp(0, 9);
  }

  Future<void> _submitAnswers() async {
    // 1) Đảm bảo user_id đã load hợp lệ
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // 2) Kiểm tra đã trả lời hết chưa
    final totalQuestionsExpected = partAnswers.values.fold<int>(
      0,
          (sum, list) => sum + list.length,
    );
    final totalProvided = userAnswers.values.fold<int>(
      0,
          (sum, m) => sum + m.length,
    );
    if (totalProvided < totalQuestionsExpected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    try {
      // 3) Tính totalCorrect và chuẩn bị list upsert
      int totalCorrect = 0;
      final correctByPart = <int,int>{};
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

      // 4) Manual upsert vào user_answers
      for (final rec in answersUpsert) {
        final partId = rec['part_id'] as int;
        final qNo    = rec['question_number'] as int;

        final exists = await Supabase.instance.client
            .from('user_answers')
            .select()
            .eq('user_id', rec['user_id'])
            .eq('part_id', partId)
            .eq('question_number', qNo);

        if (exists is List && exists.isNotEmpty) {
          // update nếu đã tồn tại
          await Supabase.instance.client
              .from('user_answers')
              .update({
            'user_answer': rec['user_answer'],
            'is_correct' : rec['is_correct'],
          })
              .eq('user_id', rec['user_id'])
              .eq('part_id', partId)
              .eq('question_number', qNo);
        } else {
          // insert nếu chưa có
          await Supabase.instance.client
              .from('user_answers')
              .insert([rec]);
        }
      }

      // 5) Tính điểm thang IELTS (0–9)
      final rawScore = totalQuestionsExpected > 0
          ? (totalCorrect / totalQuestionsExpected) * 9
          : 0.0;
      final score = rawScore.clamp(0, 9).toDouble();

      // 6) Chuẩn bị record cho test_results
      final resultRecord = {
        'user_id'        : userId,
        'test_id'        : widget.testId,
        'score'          : score.toInt(),
        'total_questions': totalQuestionsExpected,
        'time'           : remainingTime,
        // Lưu số đúng từng part nếu cần
        if (correctByPart.containsKey(1)) 'part1': correctByPart[1].toString(),
        if (correctByPart.containsKey(2)) 'part2': correctByPart[2].toString(),
        if (correctByPart.containsKey(3)) 'part3': correctByPart[3].toString(),
      };

      // 7) Manual upsert vào test_results
      final existsRes = await Supabase.instance.client
          .from('test_results')
          .select()
          .eq('user_id', userId)
          .eq('test_id', widget.testId);

      if (existsRes is List && existsRes.isNotEmpty) {
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

      // 8) Xóa cache tạm
      final box = await Hive.openBox('progress');
      await box.delete('listening_test_in_progress_${widget.testId}');

      // 9) Thông báo & chuyển màn hình
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted! Your Listening score: ${score.toStringAsFixed(1)}')),
      );
      _timer?.cancel();
      await _audioPlayer.stop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingDone(
            score: score,
            timeTaken: totalTime-remainingTime,
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
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final ok = await _showExitConfirmation();
        return ok;
      },
      child: Theme(
        data: isDarkMode
            ? ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.blue,
        )
            : ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.blue,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Listening Test'),
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
                  itemBuilder: (ctx, i) {
                    final part = parts[i];
                    final answers = partAnswers[part['id']] ?? [];
                    return PartWidget(
                      part: part,
                      answers: answers,
                      audioPlayer: _audioPlayer,
                      userAnswers: userAnswers[part['id']] ?? {},
                      onAnswerChanged: (qNo, ans) {
                        _onAnswerChanged(part['id'], qNo, ans);
                      },
                    );
                  },
                ),
              Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('Time: ${_formatTime(remainingTime)}',
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
  final AudioPlayer audioPlayer;
  final Map<int, String> userAnswers;
  final void Function(int, String) onAnswerChanged;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(part['part_title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(part['part_description'] ?? 'No description'),
            const SizedBox(height: 10),
            if (part['audio_url'] != null)
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.green),
                onPressed: () => audioPlayer.play(UrlSource(part['audio_url'])),
              ),
            const SizedBox(height: 10),
            ...answers.map((ans) => FillInTheBlankQuestion(
              questionText: 'Question ${ans['question_number']}',
              initialAnswer: userAnswers[ans['question_number']] ?? '',
              onAnswerSubmitted: (val) =>
                  onAnswerChanged(
                    ans['question_number'],
                    (val ?? '').trim(),
                  ),
            )),
          ],
        ),
      ),
    );
  }
}
