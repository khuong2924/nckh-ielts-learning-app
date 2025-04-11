import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Vocabulary.dart';
import '../../components/CustomAppBar.dart';
import '../../components/BottomNavBar.dart';

class FlashcardLearning extends StatefulWidget {
  final String flashcardId;
  const FlashcardLearning({Key? key, required this.flashcardId}) : super(key: key);

  @override
  State<FlashcardLearning> createState() => _FlashcardLearningState();
}

class _FlashcardLearningState extends State<FlashcardLearning> with SingleTickerProviderStateMixin {
  List<Vocabulary> vocabList = [];
  int currentIndex = 0;
  bool isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final FlutterTts flutterTts = FlutterTts();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadUserIdAndData();
  }

  Future<void> _loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    final response = await Supabase.instance.client
        .from('flashcard_words')
        .select()
        .eq('flashcard_id', widget.flashcardId);

    final List<Vocabulary> list = (response as List).map((e) => Vocabulary.fromMap(e)).toList();

    // Load trạng thái học của người dùng
    for (var word in list) {
      final progress = await Supabase.instance.client
          .from('user_vocabulary_progress')
          .select()
          .match({'user_id': userId, 'vocabulary_id': word.id});

      if (progress.isNotEmpty) {
        word.isFavorite = progress[0]['is_favorite'] ?? false;
        word.isLearned = progress[0]['is_learned'] ?? false;
      }
    }

    setState(() => vocabList = list);
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
    if (currentIndex < vocabList.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  void _handlePrev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  Future<void> _handlePronounce() async {
    final word = vocabList[currentIndex].englishWord;
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(word);
  }

  Future<void> _toggleFavorite() async {
    final word = vocabList[currentIndex];
    setState(() => word.isFavorite = !word.isFavorite);

    await Supabase.instance.client
        .from('user_vocabulary_progress')
        .upsert({
      'user_id': userId,
      'vocabulary_id': word.id,
      'is_favorite': word.isFavorite,
    }, onConflict: 'user_id, vocabulary_id');

  }

  Future<void> _toggleLearned() async {
    final word = vocabList[currentIndex];
    setState(() => word.isLearned = !word.isLearned);

    await Supabase.instance.client
        .from('user_vocabulary_progress')
        .upsert({
      'user_id': userId,
      'vocabulary_id': word.id,
      'is_learned': word.isLearned,
    },  onConflict: 'user_id, vocabulary_id');
  }

  Widget _buildFlashcard(Vocabulary word) {
    return GestureDetector(
      onTap: () => setState(() => isFlipped = !isFlipped),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 320, maxHeight: 320), // 🔷 nhỏ gọn, hình vuông
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
            ],
          ),
          child: isFlipped
              ? Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    word.englishWord,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0067AC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (word.pronunciation != null) ...[
                    SizedBox(height: 6),
                    Text(
                      "/${word.pronunciation}/",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 10),
                  Text(
                    word.meaning,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (word.example != null && word.example!.trim().isNotEmpty) ...[
                    SizedBox(height: 10),
                    Text(
                      '"${word.example}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 14),
                  IconButton(
                    icon: Icon(Icons.volume_up_rounded, size: 24, color: Color(0xFF0067AC)),
                    onPressed: _handlePronounce,
                  ),
                ],
              ),
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: word.imageUrl != null && word.imageUrl!.isNotEmpty
                ? Image.network(
              word.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stack) =>
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            )
                : Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    if (vocabList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Flashcard")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final word = vocabList[currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text("Flashcard")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / vocabList.length,
              backgroundColor: Colors.grey[300],
              color: Color(0xFF0067AC),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFlashcard(word),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(word.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                      onPressed: _toggleFavorite,
                    ),
                    IconButton(
                      icon: Icon(word.isLearned ? Icons.check_circle : Icons.check_circle_outline,
                          color: Color(0xFF0067AC)),
                      onPressed: _toggleLearned,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: _handlePrev),
                Text("${currentIndex + 1}/${vocabList.length}"),
                IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: _handleNext),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    flutterTts.stop();
    super.dispose();
  }
}
