import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/Vocabulary.dart';

class VocabularyItem extends StatelessWidget {
  final Vocabulary vocabulary;
  final ValueChanged<bool>? onLearningStatusChanged;
  final ValueChanged<bool>? onFavoriteChanged;

  const VocabularyItem({
    Key? key,
    required this.vocabulary,
    this.onLearningStatusChanged,
    this.onFavoriteChanged,
  }) : super(key: key);

  Future<void> _updateVocabularyStatus(String userId, String vocabId, bool isLearned, bool isFavorite) async {
    final response = await Supabase.instance.client
        .from('user_vocabulary_progress')
        .update({
      'is_learned': isLearned,
      'is_favorite': isFavorite,
    })
        .eq('user_id', userId)
        .eq('vocabulary_id', vocabId)
        .select() // Lấy dữ liệu đã cập nhật
        .single();
  }

  Future<String> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Hoặc một widget khác để hiển thị trạng thái tải
        } else if (snapshot.hasError) {
          return Text('Error loading user ID');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('User ID is empty');
        }

        final userId = snapshot.data!; // Lấy userId từ snapshot

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          height: 55,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    vocabulary.englishWord,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: double.infinity,
                color: Color(0xFF0067AC),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    vocabulary.vietnameseWord,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  vocabulary.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Color(0xFF0067AC),
                ),
                onPressed: () async {
                  final newFavoriteStatus = !vocabulary.isFavorite;
                  // Cập nhật trạng thái yêu thích ngay lập tức
                  onFavoriteChanged?.call(newFavoriteStatus);
                  await _updateVocabularyStatus(userId, vocabulary.id, vocabulary.isLearned, newFavoriteStatus);
                },
              ),
              IconButton(
                icon: Icon(
                  vocabulary.isLearned ? Icons.check_circle : Icons.check_circle_outline,
                  color: Color(0xFF0067AC),
                ),
                onPressed: () async {
                  // Cập nhật trạng thái học tập ngay lập tức
                  final newLearningStatus = !vocabulary.isLearned;
                  // Cập nhật trạng thái học tập trong giao diện
                  onLearningStatusChanged?.call(newLearningStatus);
                  // Cập nhật vào Supabase
                  await _updateVocabularyStatus(userId, vocabulary.id, newLearningStatus, vocabulary.isFavorite);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}