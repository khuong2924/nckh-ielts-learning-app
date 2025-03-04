import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTests() async {
    final response = await supabase.from('tests').select();

    if (response.isEmpty) {
      throw Exception('No tests found.');
    }

    return List<Map<String, dynamic>>.from(response);
  }


  Future<void> addTest(Map<String, dynamic> test) async {
    final response = await supabase.from('tests').insert(test);

    if (response.isEmpty) {
      throw Exception('Error adding test: No data returned.');
    }
  }
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
