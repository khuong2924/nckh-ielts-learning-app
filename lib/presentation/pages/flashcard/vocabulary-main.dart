import 'package:auth/presentation/pages/flashcard/vocabulary-item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/AddVocabularyDialog.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Vocabulary.dart';
import 'flashcard-learning.dart';
import '../../model/learning-category.dart';
import 'package:auth/presentation/pages/flashcard/learning-category-card.dart';
import 'package:auth/presentation/pages/flashcard/flashcard-quiz.dart';
import 'package:auth/presentation/pages/flashcard/flashcard-test-typing.dart';

class VocabularyMain extends StatefulWidget {
  final String topicId;

  const VocabularyMain({Key? key, required this.topicId}) : super(key: key);

  @override
  State<VocabularyMain> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Vocabulary> vocabularies = [];
  late String userId;

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final box = await Hive.openBox('app_box');
    userId = box.get('user_id', defaultValue: '') ?? '';
    await _loadVocabularyForTopic(widget.topicId);
    await ensureFlashcardProgressInitialized(widget.topicId, userId);
  }
  Future<void> _loadVocabularyForTopic(String topicId) async {
    final response = await Supabase.instance.client
        .from('flashcard_words')
        .select('id, word, meaning, pronunciation, part_of_speech, example, audio_url, image_url, create_by')
        .eq('flashcard_id', topicId);

    final vocabList = (response as List)
        .map((e) => Vocabulary(
      id: e['id'],
      englishWord: e['word'],
      meaning: e['meaning'],
      pronunciation: e['pronunciation'],
      partOfSpeech: e['part_of_speech'],
      example: e['example'],
      audioUrl: e['audio_url'],
      imageUrl: e['image_url'],           // ✅ THÊM DÒNG NÀY
      isLearned: false,
      isFavorite: false,
      createdBy: e['create_by'],
    ))
        .where((vocab) =>
    vocab.createdBy == null ||
        vocab.createdBy == userId ||
        vocab.createdBy == 'admin')
        .toList();

    for (var vocab in vocabList) {
      final progressResponse = await Supabase.instance.client
          .from('user_vocabulary_progress')
          .select()
          .eq('user_id', userId)
          .eq('vocabulary_id', vocab.id);

      if (progressResponse.isNotEmpty) {
        final progressData = progressResponse[0];
        vocab.isLearned = progressData['is_learned'] ?? false;
        vocab.isFavorite = progressData['is_favorite'] ?? false;
      } else {
        // ✅ Dùng upsert để tránh duplicate, nếu có race condition
        await Supabase.instance.client
            .from('user_vocabulary_progress')
            .upsert({
          'user_id': userId,
          'vocabulary_id': vocab.id,
          'is_learned': false,
          'is_favorite': false,
        }, onConflict: 'user_id,vocabulary_id',);
      }
    }

    setState(() {
      vocabularies = vocabList;
    });
  }
  Future<void> ensureFlashcardProgressInitialized(String flashcardId, String userId) async {
    final existing = await Supabase.instance.client
        .from('flashcards_progress')
        .select()
        .eq('flashcard_id', flashcardId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await Supabase.instance.client.from('flashcards_progress').insert({
        'flashcard_id': flashcardId,
        'user_id': userId,
        'progress': 0,
      });
    }
  }


  @override
  void dispose() {
    updateFlashcardProgress(
      flashcardId: widget.topicId,
      userId: userId,
    );
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFC5E8FF)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLearningSection(),
                      _buildVocabularySection(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildVocabularyList(vocabularies),
                            _buildVocabularyList(vocabularies
                                .where((v) => !v.isLearned)
                                .toList()),
                            _buildVocabularyList(vocabularies
                                .where((v) => v.isLearned)
                                .toList()),
                            _buildVocabularyList(vocabularies
                                .where((v) => v.isFavorite)
                                .toList()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BottomNavBar(
                currentIndex: 1,
                onTap: (index) async {
                  await updateFlashcardProgress(flashcardId: widget.topicId, userId: userId);
                },
              ),

            ],
          ),
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
                onTap: () async {
                  if (learningCategories[index].title == 'FlashCard') {
                    // Điều hướng đến FlashcardLearning với ID topic
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardLearning(
                            flashcardId: widget.topicId), // Sử dụng topicId
                      ),
                    );
                  } else if (learningCategories[index].title == 'Gõ từ') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardTyping(topicId: widget.topicId),
                      ),
                    );

                    if (result == true) {
                      _loadVocabularyForTopic(widget.topicId); // reload lại dữ liệu
                    }
                  } else if (learningCategories[index].title == 'Trắc nghiệm') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashCardQuiz(topicId: widget.topicId),
                      ),
                    );

                    if (result == true) {
                      _loadVocabularyForTopic(widget.topicId); // Reload lại dữ liệu học
                    }

                  }
                },
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
                icon: Icon(Icons.add),
                onPressed: () async {
                  final added = await showDialog(
                    context: context,
                    builder: (context) => AddVocabularyDialog(topicId: widget.topicId, userId: userId),
                  );
                  if (added == true) {
                    _loadVocabularyForTopic(widget.topicId);
                  }
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
  Future<void> updateFlashcardProgress({
    required String flashcardId,
    required String userId,
  }) async {
    // Lấy danh sách từ vựng thuộc flashcard
    final wordIdsResponse = await Supabase.instance.client
        .from('flashcard_words')
        .select('id')
        .eq('flashcard_id', flashcardId);

    final wordIds = (wordIdsResponse as List)
        .map((e) => e['id'] as String)
        .toList();

    if (wordIds.isEmpty) return;

    // Đếm số từ đã học
    final learnedCountResponse = await Supabase.instance.client
        .from('user_vocabulary_progress')
        .select('vocabulary_id')
        .inFilter('vocabulary_id', wordIds)
        .eq('user_id', userId)
        .eq('is_learned', true);

    final learnedCount = learnedCountResponse.length;
    // Cập nhật flashcards_progress
    await Supabase.instance.client
        .from('flashcards_progress')
        .update({'progress': learnedCount})
        .match({
      'user_id': userId,
      'flashcard_id': flashcardId,
    });
  }

  Widget _buildVocabularyList(List<Vocabulary> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return VocabularyItem(
          vocabulary: items[index],
          canEdit: items[index].createdBy == userId,
          onLearningStatusChanged: (value) async {
            setState(() {
              final vocabIndex = vocabularies.indexOf(items[index]);
              vocabularies[vocabIndex] =
                  vocabularies[vocabIndex].copyWith(isLearned: value);
            });
            final updated = vocabularies[index];
            await Supabase.instance.client
                .from('user_vocabulary_progress')
                .update({
              'is_learned': updated.isLearned,
              'is_favorite': updated.isFavorite,
            }).match({
              'user_id': userId,
              'vocabulary_id': updated.id,
            });
          },
          onFavoriteChanged: (value) async {
            setState(() {
              final vocabIndex = vocabularies.indexOf(items[index]);
              vocabularies[vocabIndex] =
                  vocabularies[vocabIndex].copyWith(isFavorite: value);
            });
            final updated = vocabularies[index];
            await Supabase.instance.client
                .from('user_vocabulary_progress')
                .update({
              'is_learned': updated.isLearned,
              'is_favorite': updated.isFavorite,
            }).match({
              'user_id': userId,
              'vocabulary_id': updated.id,
            });
          },
          onEdit: () async {
            final updated = await showDialog(
              context: context,
              builder: (context) => AddVocabularyDialog(
                topicId: widget.topicId,
                userId: userId,
                existingVocabulary: items[index],
              ),
            );
            if (updated == true) {
              await _loadVocabularyForTopic(widget.topicId);
            }
          },
          onDelete: () async {
            final confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text('Are you sure you want to delete this vocabulary?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              final vocabId = items[index].id;
              await Supabase.instance.client
                  .from('flashcard_words')
                  .delete()
                  .eq('id', vocabId);
              await Supabase.instance.client
                  .from('user_vocabulary_progress')
                  .delete()
                  .eq('vocabulary_id', vocabId)
                  .eq('user_id', userId);
              await _loadVocabularyForTopic(widget.topicId);
            }
          },
        );
      },
    );
  }
}
