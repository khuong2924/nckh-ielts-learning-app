import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Đảm bảo import Supabase
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Flashcards.dart';
import '../../model/Vocabulary.dart';
import 'package:flutter_tts/flutter_tts.dart';
class FlashcardLearning extends StatefulWidget {
  final String flashcardId; // Nhận ID flashcard

  const FlashcardLearning({Key? key, required this.flashcardId}) : super(key: key);

  @override
  State<FlashcardLearning> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardLearning>
    with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentWordIndex = 0;
  late Flashcard _flashcard;
  List<Vocabulary> words = []; // Danh sách từ vựng
  int userProgress = 0; // Tiến trình của người dùng
  FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadFlashcardData(widget.flashcardId); // Gọi hàm để tải dữ liệu flashcard
  }
  Future<void> _handlePronunciation() async {
    final word = words[currentWordIndex].englishWord;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5); // Tốc độ nói
    await flutterTts.setPitch(1.0); // Cao độ giọng nói
    await flutterTts.speak(word); // Đọc từ vựng
  }
  Future<void> _loadFlashcardData(String flashcardId) async {
    try {
      final response = await Supabase.instance.client
          .from('flashcards')
          .select()
          .eq('id', flashcardId)
          .single();
      print(response);
      if (response != null) {
        // Kiểm tra từng trường có giá trị không null
        final flashcard = response; // Giả sử response trả về một đối tượng

        String topic = flashcard['topic'] ?? 'Unknown Topic';
        int totalWords = flashcard['total_words'] ?? 0;
        String createdAt = flashcard['created_at'] ?? '';
        String author = flashcard['author'] ?? 'Unknown Author';

        setState(() {
          _flashcard = Flashcard(
            id: flashcard['id'],
            topic: flashcard['topic'],
            totalWords: flashcard['total_words'],
            createdAt: DateTime.parse(flashcard['created_at']),
          );
        });

        await _loadVocabulary(); // Gọi sau khi cập nhật flashcard

        print('Flashcard created: $topic');
      } else {
        print('No flashcard found with the given ID.');
      }
    } catch (e) {
      print('Error loading flashcard data: $e'); // Ghi lỗi
    }
  }

  Future<void> _loadVocabulary() async {
    try {
      final response = await Supabase.instance.client
          .from('flashcard_words')
          .select()
          .eq('flashcard_id', _flashcard.id);

      // Chắc chắn rằng phản hồi có chứa dữ liệu
      if (response != null && response is List) {
        final List<Vocabulary> loadedWords = response
            .map((item) => Vocabulary.fromMap(item))
            .toList();

        setState(() {
          words = loadedWords; // Cập nhật danh sách từ vựng
        });
      } else {
        print('No vocabulary found for this flashcard.'); // Nếu không có từ vựng
      }
    } catch (e) {
      print('Error fetching vocabulary: $e'); // Ghi lỗi
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _handleNext() {
    if (currentWordIndex < words.length - 1) {
      setState(() {
        currentWordIndex++;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  void _handleBack() {
    if (currentWordIndex > 0) {
      setState(() {
        currentWordIndex--;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  Widget _buildProgressSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$userProgress/${_flashcard.totalWords}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0067AC),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: userProgress / _flashcard.totalWords,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordDetailsCard(Vocabulary word) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              word.imageUrl ?? '', // Kiểm tra null
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pronunciation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    word.pronunciation ?? 'N/A', // Kiểm tra null
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF0067AC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: Color(0xFF0067AC),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _handlePronunciation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Vocabulary word) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            word.meaning ?? 'N/A', // Kiểm tra null
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(Vocabulary word) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(3.14159 * _animation.value),
            alignment: Alignment.center,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _animation.value < 0.5
                        ? Text(
                      word.englishWord,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067AC),
                      ),
                    )
                        : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: Text(
                        word.vietnameseWord,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF0067AC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          color: Color(0xFF0067AC),
                          size: 28,
                        ),
                        onPressed: _handlePronunciation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(child: CircularProgressIndicator()); // Hiển thị loading
    }

    final currentWord = words[currentWordIndex];
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
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  CustomAppBar(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _flashcard.topic,
                              style: TextStyle(
                                color: Color(0xFF202244),
                                fontSize: 24,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              color: Color(0xFF0067AC),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              color: Color(0xFF0067AC),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressSection(),
                      _buildWordDetailsCard(currentWord),
                      _buildDescriptionCard(currentWord),
                      _buildFlashcard(currentWord),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, -4),
            blurRadius: 15,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Back
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0067AC), Color(0xFF0088DC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0067AC).withOpacity(0.3),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleBack,
                      borderRadius: BorderRadius.circular(21),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Tap to flip indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0067AC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF0067AC).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFF0067AC),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Tap to flip',
                        style: TextStyle(
                          color: Color(0xFF0067AC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nút Next
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0067AC), Color(0xFF0088DC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0067AC).withOpacity(0.3),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleNext,
                      borderRadius: BorderRadius.circular(21),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            BottomNavBar(currentIndex: 1, onTap: (int) {}),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
      String text,
      IconData icon,
      EdgeInsets padding,
      VoidCallback onPressed,
      ) {
    return Container(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0067AC),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: padding,
              child: Icon(icon, size: 18),
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}