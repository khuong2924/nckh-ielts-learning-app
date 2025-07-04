import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth/presentation/pages/flashcard/vocabulary-main.dart';
import '../../model/FlashCards.dart';
import '../../model/FlashcardProgress.dart';
import '../../route_persistence.dart';

class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});

  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Flashcard> _flashcards = [];
  List<FlashcardProgress> _progressList = [];
  int _currentIndex = 1;
  late String userId;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Mock data for statistics
  late int _totalWords = 0;
  late int _learnedWords = 0;


  @override
  void initState() {
    super.initState();
    saveLastRoute('flashcard_home'); // Thêm dòng này!
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadUserId();
    _animationController.forward();
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final box = await Hive.openBox('app_box');
    userId = box.get('user_id', defaultValue: '') ?? '';
    await _loadFlashcards();

    if (_flashcards.isNotEmpty) {
      await _loadFlashcardsProgress();
    }
    _loadOverallStatistics();
  }

  Future<void> _loadFlashcards() async {
    final response = await _supabase
        .from('flashcards')
        .select()
        .or('author.eq.$userId,author.is.null,author.eq.admin');

    if (response != null && response.isNotEmpty) {
      setState(() {
        _flashcards = response.map((e) => Flashcard.fromMap(e)).toList();
      });
    } else {
      print('Error loading flashcards');
    }
  }

  Future<String?> _showEditTopicDialog(String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Topic"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Topic Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.pop(context, newTitle);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> _loadFlashcardsProgress() async {
    if (userId.isNotEmpty) {
      final progressResponse = await _supabase
          .from('flashcards_progress')
          .select()
          .eq('user_id', userId);

      if (progressResponse != null && progressResponse.isNotEmpty) {
        setState(() {
          _progressList = progressResponse.map((e) => FlashcardProgress.fromMap(e)).toList();
        });
      } else {
        // Nếu chưa có thì tạo mới với progress = 0
        for (var flashcard in _flashcards) {
          await _createProgressForFlashcard(flashcard.id);
        }
      }
    }
  }


  Future<void> _createProgressForFlashcard(String flashcardId) async {
    final response = await _supabase.from('flashcards_progress').insert({
      'user_id': userId,
      'flashcard_id': flashcardId,
      'progress': 0, // Initial progress is 0
    });

    if (response != null && response.error != null) {
      print('Error creating progress for flashcard: ${response.error!.message}');
    } else {
      print('Created progress for flashcard: $flashcardId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {
                // Handle notifications
              },
            ),
            Expanded(
              child: FadeTransition(
                opacity: _animation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildStatisticsCards(),
                      const SizedBox(height: 24),
                      _buildTopicHeader(),
                      const SizedBox(height: 16),
                      _buildTopicList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Flashcards',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202244),
                fontFamily: 'Montserrat-Bold',
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4681DA).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'lib/icons/ic-search.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF4681DA),
                    BlendMode.srcIn,
                  ),
                  height: 20,
                ),
              ),
              onPressed: () {
                // Handle search
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Enhance your vocabulary with smart flashcards',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Montserrat-Medium',
          ),
        ),
      ],
    );
  }
  Future<void> _loadOverallStatistics() async {
    final userId = this.userId;

    // Lấy tất cả từ user đã học
    final learnedWordsRes = await Supabase.instance.client
        .from('user_vocabulary_progress')
        .select('vocabulary_id')
        .eq('user_id', userId)
        .eq('is_learned', true);

    final totalWordsRes = await Supabase.instance.client
        .from('user_vocabulary_progress')
        .select('vocabulary_id')
        .eq('user_id', userId);

    setState(() {
      _learnedWords = (learnedWordsRes as List).length;
      _totalWords = (totalWordsRes as List).length;
    });
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4681DA), Color(0xFF2A4ECA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4681DA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Montserrat-Bold',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Words', '$_totalWords', Icons.book_outlined),
              _buildStatCard('Learned', '$_learnedWords', Icons.check_circle_outline),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _totalWords > 0 ? _learnedWords / _totalWords : 0,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _totalWords > 0
                ? '${(_learnedWords / _totalWords * 100).toStringAsFixed(1)}% Complete'
                : '0% Complete',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontFamily: 'Montserrat-Medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Montserrat-Bold',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontFamily: 'Montserrat-Medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Topics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202244),
            fontFamily: 'Montserrat-Bold',
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Flashcards',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202244),
                fontFamily: 'Montserrat-Bold',
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4681DA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF4681DA), size: 22),
                  ),
                  onPressed: () async {
                    final created = await _showCreateFlashcardDialog();
                    if (created) {
                      await _loadFlashcards();
                      await _loadFlashcardsProgress();
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4681DA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'lib/icons/ic-search.svg',
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4681DA),
                        BlendMode.srcIn,
                      ),
                      height: 20,
                    ),
                  ),
                  onPressed: () {
                    // Handle search
                  },
                ),
              ],
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Show all topics
          },
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4681DA),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat-SemiBold',
            ),
          ),
        ),
      ],
    );
  }
  Future<bool> _showCreateFlashcardDialog() async {
    final TextEditingController _topicController = TextEditingController();

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Number of Words',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: const Text(
                '0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final topic = _topicController.text.trim();
              if (topic.isNotEmpty) {
                await _supabase.from('flashcards').insert({
                  'topic': topic,
                  'total_words': 0,
                  'author': userId,
                });

                Navigator.pop(context, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ) ?? false;
  }


  Widget _buildTopicList() {
    if (_flashcards.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _flashcards.length,
      itemBuilder: (context, index) {
        final flashcard = _flashcards[index];
        final progress = _progressList.firstWhere(
          (p) => p.flashcardId == flashcard.id,
          orElse: () => FlashcardProgress(
            id: 0,
            userId: userId,
            flashcardId: flashcard.id,
            progress: 0,
          ),
        ).progress;

        return _buildTopicCard(
          flashcard.topic,
          flashcard.totalWords.toString(),
          progress,
          flashcard.id,
          getRandomColor(index),
          flashcard.author,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No flashcard topics yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your flashcard topics will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color getRandomColor(int index) {
    final colors = [
      const Color(0xFF4681DA),
      const Color(0xFF3AB19B),
      const Color(0xFFE33629),
      const Color(0xFFFFAB40),
      const Color(0xFF8E74EA),
    ];
    return colors[index % colors.length];
  }

  Widget _buildTopicCard(
      String title,
      String totalWords,
      int currentProgress,
      String topicId,
      Color accentColor,
      String? author,
      ) {
    print('🧪 author: [$author], userId: [$userId], match: ${author?.trim() == userId.trim()}');
    double progressPercent = int.parse(totalWords) > 0
        ? currentProgress / int.parse(totalWords)
        : 0.0;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => VocabularyMain(topicId: topicId),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );

        // Nếu result là true thì reload progress
        if (result == true) {
          await _loadFlashcardsProgress();
        }
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF202244),
                            fontFamily: 'Montserrat-Bold',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total: $totalWords words',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Montserrat-Medium',
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: progressPercent,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoBadge(
                    'Learned',
                    '$currentProgress/$totalWords',
                    Icons.check_circle_outline,
                    accentColor,
                  ),
                  _buildInfoBadge(
                    'Progress',
                    '${(progressPercent * 100).toInt()}%',
                    Icons.trending_up,
                    accentColor,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text('Start', style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-Bold',
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (author != null && author.trim() == userId.trim())
                    Row(
                      children: [
                        // 🟦 Nút sửa
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.orangeAccent),
                          onPressed: () async {
                            final newTopic = await _showEditTopicDialog(title);
                            if (newTopic != null && newTopic != title) {
                              await Supabase.instance.client
                                  .from('flashcards')
                                  .update({'topic': newTopic})
                                  .eq('id', topicId);
                              await _loadFlashcards();
                            }
                          },
                        ),

                        // 🟥 Nút xóa
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            final confirmed = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Topic"),
                                content: const Text("This will also delete all vocabulary in this topic. Are you sure?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              // 🔥 Xoá toàn bộ vocabulary thuộc topic này
                              await Supabase.instance.client
                                  .from('flashcard_words')
                                  .delete()
                                  .eq('flashcard_id', topicId);

                              // 🔥 Xoá topic
                              await Supabase.instance.client
                                  .from('flashcards')
                                  .delete()
                                  .eq('id', topicId);

                              await _loadFlashcards();
                              await _loadFlashcardsProgress();
                            }
                          },
                        ),
                      ],
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202244),
                fontFamily: 'Montserrat-Bold',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'Montserrat-Medium',
              ),
            ),
          ],
        ),
      ],
    );
  }
}