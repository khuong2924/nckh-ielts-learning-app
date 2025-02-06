import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth/presentation/pages/flashcard/vocabulary-main.dart';
import '../../model/FlashCards.dart';


class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});

  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Flashcard> _flashcards = [];
  List<FlashcardProgress> _progressList = [];
  int _currentIndex = 0;
  late String userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    await _loadFlashcards();
    await _loadFlashcardsProgress(); // Tải tiến trình flashcards sau khi tải flashcards
  }

  Future<void> _loadFlashcards() async {
    final response = await _supabase.from('flashcards').select();

    if (response != null && response.length > 0) {
      setState(() {
        _flashcards = response.map((e) => Flashcard.fromMap(e)).toList();
      });
    } else {
      print('Lỗi khi tải flashcards');
    }
  }

  Future<void> _loadFlashcardsProgress() async {
    if (userId.isNotEmpty) {
      final progressResponse = await _supabase
          .from('flashcards_progress')
          .select()
          .eq('user_id', userId);

      if (progressResponse != null && progressResponse.length > 0) {
        setState(() {
          _progressList = progressResponse.map((e) => FlashcardProgress.fromMap(e)).toList();
        });
      } else {
        // Nếu không tìm thấy tiến trình, tạo bản ghi mới cho mỗi flashcard
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
      'progress': 0, // Tiến trình khởi đầu là 0
    });

    if (response.error != null) {
      print('Lỗi khi tạo tiến trình cho flashcard: ${response.error!.message}');
    } else {
      print('Đã tạo tiến trình cho flashcard: $flashcardId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {
                // Handle notifications
              },
            ),
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _flashcards.map((flashcard) {
                    final progress = _progressList.firstWhere(
                          (p) => p.flashcardId == flashcard.id,
                      orElse: () => FlashcardProgress(
                        id: 0,
                        userId: userId,
                        flashcardId: flashcard.id,
                        progress: 0,
                      ),
                    ).progress;

                    return _buildRoundedContainer(
                      flashcard.topic,
                      flashcard.topic,
                      flashcard.totalWords.toString(),
                      progress.toString(),
                      flashcard.id, // Truyền id flashcard
                    );
                  }).toList(),
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

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset('lib/icons/ic-back.svg'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'FlashCard',
            style: TextStyle(
              color: Color(0xFF202244),
              fontSize: 21,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedContainer(
      String author, String nameTopic, String numberWords, String progress, String topicId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VocabularyMain(topicId: topicId), // Chuyển đến VocabularyMain
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'By',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202244),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              nameTopic,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 29,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(0xFF4681DA).withOpacity(0.69),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Words: $numberWords',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 50),
                Row(
                  children: [
                    Container(
                      width: 29,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(0xFF4681DA).withOpacity(0.69),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            value: double.parse(progress) / double.parse(numberWords),
                            strokeWidth: 3,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$progress/$numberWords',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}