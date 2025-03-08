import 'package:auth/presentation/pages/reading/reading-home.dart';
import 'package:auth/presentation/pages/writing/writing-page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auth/presentation/pages/test-page/listening-page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/presentation/pages/test-page/viewanswer.dart';

class TestCard extends StatelessWidget {
  final String? title;
  final String? testType;
  final int? testId;

  const TestCard({
    Key? key,
    this.title,
    this.testType,
    this.testId,
  }) : super(key: key);

  factory TestCard.fromJson(Map<String, dynamic> json) {
    return TestCard(
      title: json['test_name'],
      testType: json['test_type'],
      testId: json['id'],
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  Future<Map<int, String>> _getUserAnswers(String userId, int partId) async {
    final response = await Supabase.instance.client
        .from('user_answers')
        .select('question_number, user_answer')
        .eq('user_id', userId)
        .eq('part_id', partId);

    final userAnswers = <int, String>{};
    for (var item in response) {
      if (item['question_number'] == null || item['user_answer'] == null) {
        debugPrint("Lỗi dữ liệu user_answers: $item");
        continue;
      }
      userAnswers[item['question_number']] = item['user_answer'];
    }

    debugPrint("Dữ liệu userAnswers: $userAnswers");
    return userAnswers;
  }

  Future<List<Map<String, dynamic>>> _getPartAnswers(int partId) async {
    final response = await Supabase.instance.client
        .from('answers')
        .select('id, part_id, question_number, correct_answer')
        .eq('part_id', partId);

    final partAnswers = <Map<String, dynamic>>[];

    for (var item in response) {
      if (item['id'] == null || item['question_number'] == null || item['correct_answer'] == null) {
        debugPrint("Lỗi dữ liệu: $item");
        continue;
      }

      partAnswers.add({
        'id': item['id'],
        'part_id': item['part_id'],
        'question_number': item['question_number'],
        'correct_answer': item['correct_answer'],
      });
    }

    debugPrint("Dữ liệu partAnswers: $partAnswers");
    return partAnswers;
  }

  Future<bool> _hasResult() async {
    final userId = await _getUserId();
    if (userId == null || testId == null) return false;

    final response = await Supabase.instance.client
        .from('test_results')
        .select()
        .eq('user_id', userId)
        .eq('test_id', testId!)
        .maybeSingle();

    return response != null && response.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> _getParts(int testId) async {
    final response = await Supabase.instance.client
        .from('listening_parts')
        .select('id, part_title, part_description')
        .eq('test_id', testId);

    return response;
  }

  Future<void> _navigateToViewAnswers(BuildContext context) async {
    final userId = await _getUserId();
    final parts = await _getParts(testId!);

    if (userId == null || parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy dữ liệu')),
      );
      return;
    }

    final Map<int, Map<int, String>> userAnswers = {}; // Định dạng mới
    final Map<int, List<Map<String, dynamic>>> partAnswers = {};

    // Lấy dữ liệu cho tất cả các phần
    for (var part in parts) {
      final userAnswerMap = await _getUserAnswers(userId, part['id']);
      final partAnswerList = await _getPartAnswers(part['id']);

      userAnswers[part['id']] = userAnswerMap; // Thay đổi cách lưu trữ dữ liệu
      partAnswers[part['id']] = partAnswerList;
    }

    debugPrint("Final userAnswers: $userAnswers");
    debugPrint("Final partAnswers: $partAnswers");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAnswersPage(
          parts: parts,
          userAnswersPerPart: userAnswers, // Cập nhật với kiểu dữ liệu mới
          partAnswers: partAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testType ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<bool>(
                      future: _hasResult(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return const Text('Error checking results');
                        }

                        bool hasResult = snapshot.data ?? false;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120,
                              height: 36,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF0067AC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (testType == 'listening') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListeningTestPage(testId: testId!),
                                      ),
                                    );
                                  } else if (testType == 'writing') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WritingPage(testId: testId!),
                                      ),
                                    );
                                  }else if (testType == 'reading') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReadingHome(testId: testId!),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Làm bài',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (hasResult)
                              Container(
                                width: 120,
                                height: 36,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF28A745),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () => _navigateToViewAnswers(context),
                                  child: const Text(
                                    'View Answers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}