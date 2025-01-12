import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTests() async {
    final response = await supabase.from('tests').select();

    // Check if the response is empty or null
    if (response.isEmpty) {
      throw Exception('No tests found.');
    }

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addTest(Map<String, dynamic> test) async {
    final response = await supabase.from('tests').insert(test);

    // Check if the insertion was successful
    if (response.isEmpty) {
      throw Exception('Error adding test: No data returned.');
    }
  }
}