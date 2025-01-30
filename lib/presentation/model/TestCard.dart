import 'package:auth/presentation/pages/reading/reading-home.dart';
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
      userAnswers[item['question_number']] = item['user_answer'];
    }

    return userAnswers;
  }

  Future<Map<int, List<Map<String, dynamic>>>> _getPartAnswers(int partId) async {
    final response = await Supabase.instance.client
        .from('answers')
        .select('question_number, correct_answer')
        .eq('part_id', partId);

    final partAnswers = <int, List<Map<String, dynamic>>>{};

    for (var item in response) {
      final questionNumber = item['question_number'];
      final correctAnswer = item['correct_answer'];

      // Tạo danh sách câu trả lời cho từng câu hỏi
      if (!partAnswers.containsKey(questionNumber)) {
        partAnswers[questionNumber] = [];
      }
      partAnswers[questionNumber]!.add({'correct_answer': correctAnswer});
    }

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
            Container(
              width: 130,
              height: 150,
              decoration: const ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  'Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
                                  } else if (testType == 'reading') {
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
                                  onPressed: () async {
                                    final userId = await _getUserId();
                                    final parts = await _getParts(testId!);

                                    // Chỉ lấy một phần để hiển thị
                                    final part = parts.isNotEmpty ? parts[0] : null;
                                    if (part != null) {
                                      final userAnswers = await _getUserAnswers(userId!, part['id']);
                                      final partAnswers = await _getPartAnswers(part['id']);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('User asnwer: $userAnswers')),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('id: $userId')),
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewAnswersPage(
                                            parts: parts,
                                            userAnswers: userAnswers,
                                            partAnswers: partAnswers,
                                          ),
                                        ),
                                      );
                                    }
                                  },
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