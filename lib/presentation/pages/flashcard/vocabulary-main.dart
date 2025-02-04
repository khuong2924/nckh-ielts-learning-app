import 'package:auth/presentation/pages/flashcard/vocabulary-item.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Vocabulary.dart';
import 'learning-category.dart';
import 'learning-category-card.dart';

class VocabularyMain extends StatefulWidget {
  final String topicId;

  const VocabularyMain({Key? key, required this.topicId}) : super(key: key);

  @override
  State<VocabularyMain> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyMain> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Vocabulary> vocabularies = [];
  late String userId;

  // Khai báo danh sách learningCategories
  final List<LearningCategory> learningCategories = [
    LearningCategory(
      title: 'FlashCard',
      icon: Icons.style,
      color: Colors.blue,
    ),
    LearningCategory(
      title: 'Gõ từ',
      icon: Icons.keyboard,
      color: Colors.purple,
    ),
    LearningCategory(
      title: 'Trắc nghiệm',
      icon: Icons.quiz,
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    await _loadVocabularyForTopic(widget.topicId);
  }

  Future<void> _loadVocabularyForTopic(String topicId) async {
    // Lấy danh sách từ vựng có flashcard_id bằng topicId
    final response = await Supabase.instance.client
        .from('flashcard_words')
        .select()
        .eq('flashcard_id', topicId); // Không sử dụng execute

    // Chuyển đổi kết quả thành danh sách từ vựng
    final vocabList = (response as List).map((e) => Vocabulary(
      id: e['id'],
      englishWord: e['word'],
      vietnameseWord: e['meaning'],
      pronunciation: e['pronunciation'],
      partOfSpeech: e['part_of_speech'],
      example: e['example'],
      audioUrl: e['audio_url'],
      isLearned: false, // Mặc định là chưa học
      isFavorite: false, // Mặc định là chưa yêu thích
    )).toList();

    for (var vocab in vocabList) {
      final progressResponse = await Supabase.instance.client
          .from('user_vocabulary_progress')
          .select()
          .eq('user_id', userId)
          .eq('vocabulary_id', vocab.id); // Không sử dụng execute

      // Cập nhật trạng thái học tập và yêu thích
      if (progressResponse.isNotEmpty) {
        final progressData = progressResponse[0];
        vocab.isLearned = progressData['is_learned'] ?? false; // Giữ giá trị mặc định nếu không tìm thấy
        vocab.isFavorite = progressData['is_favorite'] ?? false; // Giữ giá trị mặc định nếu không tìm thấy
      } else {
        // Nếu không tìm thấy, tạo một mục mới trong bảng user_vocabulary_progress
        await Supabase.instance.client
            .from('user_vocabulary_progress')
            .insert({
          'user_id': userId,
          'vocabulary_id': vocab.id,
          'is_learned': false, // Đặt trạng thái mặc định là chưa học
          'is_favorite': false, // Đặt trạng thái mặc định là chưa yêu thích
        });
      }
    }

    setState(() {
      vocabularies = vocabList; // Cập nhật danh sách từ vựng
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFC5E8FF)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(),
            _buildLearningSection(),
            _buildVocabularySection(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVocabularyList(vocabularies),
                  _buildVocabularyList(vocabularies.where((v) => !v.isLearned).toList()),
                  _buildVocabularyList(vocabularies.where((v) => v.isLearned).toList()),
                  _buildVocabularyList(vocabularies.where((v) => v.isFavorite).toList()),
                ],
              ),
            ),
            BottomNavBar(currentIndex: 1, onTap: (int index) {}),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Learning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202244),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: learningCategories.length,
            itemBuilder: (context, index) {
              return LearningCategoryCard(
                category: learningCategories[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vocabulary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202244),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                color: Color(0xFF0067AC),
                onPressed: () {
                  // Handle add vocabulary
                },
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Color(0xFF0067AC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0067AC),
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Learning'),
            Tab(text: 'Remembered'),
            Tab(text: 'Favourite'),
          ],
        ),
      ],
    );
  }

  Widget _buildVocabularyList(List<Vocabulary> items) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return VocabularyItem(
          vocabulary: items[index],
          onLearningStatusChanged: (value) {
            setState(() {
              final vocabIndex = vocabularies.indexOf(items[index]);
              vocabularies[vocabIndex] = vocabularies[vocabIndex].copyWith(
                isLearned: value,
              );

              // Cập nhật trạng thái học tập vào bảng user_vocabulary_progress
              Supabase.instance.client
                  .from('user_vocabulary_progress')
                  .upsert({
                'user_id': userId,
                'vocabulary_id': items[index].id,
                'is_learned': value,
              });
            });
          },
          onFavoriteChanged: (value) {
            setState(() {
              final vocabIndex = vocabularies.indexOf(items[index]);
              vocabularies[vocabIndex] = vocabularies[vocabIndex].copyWith(
                isFavorite: value,
              );

              // Cập nhật trạng thái yêu thích vào bảng user_vocabulary_progress
              Supabase.instance.client
                  .from('user_vocabulary_progress')
                  .upsert({
                'user_id': userId,
                'vocabulary_id': items[index].id,
                'is_favorite': value,
              });
            });
          },
        );
      },
    );
  }
}