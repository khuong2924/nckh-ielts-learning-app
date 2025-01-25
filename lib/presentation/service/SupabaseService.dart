import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  /// Lấy danh sách bài test
  Future<List<Map<String, dynamic>>> fetchTests() async {
    final response = await supabase.from('tests').select();

    if (response.isEmpty) {
      throw Exception('No tests found.');
    }

    return List<Map<String, dynamic>>.from(response);
  }

  /// Thêm bài test mới
  Future<void> addTest(Map<String, dynamic> test) async {
    final response = await supabase.from('tests').insert(test);

    if (response.isEmpty) {
      throw Exception('Error adding test: No data returned.');
    }
  }

  /// Lấy danh sách các phần (parts) theo `test_id`
  Future<List<Map<String, dynamic>>> fetchPartsByTestId(int testId) async {
    try {
      final response = await supabase
          .from('listening_parts')
          .select('*')
          .eq('test_id', testId);

      if (response.isEmpty) {
        throw Exception('No parts found for this test.');
      }

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('Error fetching parts: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error fetching parts: $e');
      throw e;
    }
  }

  /// Lưu đáp án của người dùng
  Future<void> saveUserAnswers(int testId, Map<int, String?> answers) async {
    // Lấy user_id từ Firebase Authentication
    final firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in.');
    }
    final String userId = currentUser.uid;

    // Chuyển đổi `answers` thành một danh sách để lưu vào cơ sở dữ liệu
    final List<Map<String, dynamic>> answerList = answers.entries.map((entry) {
      return {
        'user_id': userId, // Thêm user_id vào từng câu trả lời
        'question_id': entry.key,
        'user_answer': entry.value,
        'test_id': testId,
      };
    }).toList();

    // Gửi dữ liệu lên Supabase
    final response = await supabase.from('user_answers').insert(answerList);

    if (response.error != null) {
      throw Exception('Failed to save answers: ${response.error!.message}');
    }
  }

  /// Lấy danh sách câu hỏi theo `part_id`
  Future<List<Map<String, dynamic>>> fetchQuestionsByPartId(int partId) async {
    try {
      final response = await supabase
          .from('questions')
          .select('*')
          .eq('part_id', partId);

      if (response.isEmpty) {
        throw Exception('No questions found for this part.');
      }

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('Error fetching questions for part: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error fetching questions for part: $e');
      throw e;
    }
  }
}
