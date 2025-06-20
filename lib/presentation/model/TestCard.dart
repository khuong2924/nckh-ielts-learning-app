import 'package:auth/presentation/pages/reading/reading-home.dart';
import 'package:auth/presentation/pages/writing/writing-page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auth/presentation/pages/test-page/listening-page.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/presentation/pages/test-page/viewanswer.dart';

import '../pages/writing/writing-submission.dart';

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

  // Your existing methods remain unchanged
  Future<String?> _getUserId() async {
    final box = await Hive.openBox('app_box');
    return box.get('user_id');
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
    if (userId == null || testId == null) return;

    if (testType == 'writing') {
      final result = await Supabase.instance.client
          .from('test_results')
          .select('comment, time')
          .eq('user_id', userId)
          .eq('test_id', testId!)
          .maybeSingle();

      if (result != null && result['comment'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IeltsFeedbackPage(
              testId: testId!, // ✅ truyền đúng testId
              submissions: const [], // ✅ không cần nếu đã có comment
              elapsedTime: result['time'] ?? 0,
              cachedComment: result['comment'], // ✅ phản hồi đã có sẵn
            ),
          ),
        );
        return;
      }

    }

    // fallback cho reading / listening
    final parts = await _getParts(testId!);
    final Map<int, Map<int, String>> userAnswers = {};
    final Map<int, List<Map<String, dynamic>>> partAnswers = {};

    for (var part in parts) {
      final userAnswerMap = await _getUserAnswers(userId!, part['id']);
      final partAnswerList = await _getPartAnswers(part['id']);

      userAnswers[part['id']] = userAnswerMap;
      partAnswers[part['id']] = partAnswerList;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAnswersPage(
          parts: parts,
          userAnswersPerPart: userAnswers,
          partAnswers: partAnswers,
        ),
      ),
    );
  }

  // Get appropriate icon based on test type
  IconData _getTestTypeIcon() {
    switch (testType?.toLowerCase()) {
      case 'listening':
        return Icons.headphones;
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit_note;
      case 'speaking':
        return Icons.record_voice_over;
      default:
        return Icons.quiz;
    }
  }

  // Get appropriate color based on test type
  Color _getTestTypeColor() {
    switch (testType?.toLowerCase()) {
      case 'listening':
        return const Color(0xFF3B82F6);
      case 'reading':
        return const Color(0xFFF59E0B);
      case 'writing':
        return const Color(0xFF10B981);
      case 'speaking':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final testTypeColor = _getTestTypeColor();
    final testTypeIcon = _getTestTypeIcon();
    
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -15,
              right: -15,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: testTypeColor.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: testTypeColor.withOpacity(0.05),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test type badge and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: testTypeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              testTypeIcon,
                              color: testTypeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              testType?.toUpperCase() ?? 'TEST',
                              style: TextStyle(
                                color: testTypeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Test title
                  Text(
                    title ?? 'Unknown Test',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Buttons
                  FutureBuilder<bool>(
                    future: _hasResult(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
                            ),
                          ),
                        );
                      }

                      bool hasResult = snapshot.data ?? false;

                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
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
                                } else if (testType == 'reading') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadingHome(testId: testId!),
                                    ),
                                  );
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(77), // Using withAlpha instead of withOpacity
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded, 
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              label: const Text(
                                'Start Test',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: testTypeColor,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: Color.fromRGBO(
                                  testTypeColor.red,
                                  testTypeColor.green,
                                  testTypeColor.blue,
                                  0.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                          if (hasResult) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _navigateToViewAnswers(context),
                                icon: const Icon(Icons.visibility_outlined, size: 20),
                                label: const Text('View Results'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF28A745).withOpacity(0.1),
                                  foregroundColor: const Color(0xFF28A745),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}