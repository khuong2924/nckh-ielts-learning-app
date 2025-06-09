import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Vocabulary.dart';

class FlashcardTyping extends StatefulWidget {
  final String topicId;
  const FlashcardTyping({super.key, required this.topicId});

  @override
  State<FlashcardTyping> createState() => _FlashcardTypingState();
}

class _FlashcardTypingState extends State<FlashcardTyping> {
  int _currentIndex = 1;
  final TextEditingController _answerController = TextEditingController();
  bool _isCorrect = false;
  bool _submitted = false;
  List<Vocabulary> vocabList = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  Set<String> incorrectVocabIds = {}; // lưu ID các từ sai

  late String userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final box = await Hive.openBox('app_box');
    userId = box.get('user_id', defaultValue: '') ?? '';
    fetchVocabulary();
  }

  void checkAnswer() async {
    setState(() {
      _submitted = true;
      final correct = _answerController.text.trim().toLowerCase() ==
          vocabList[currentQuestionIndex].englishWord.toLowerCase();
      _isCorrect = correct;
    });

    final vocabId = vocabList[currentQuestionIndex].id;

    if (!_isCorrect) {
      incorrectVocabIds.add(vocabId);
    } else {
      incorrectVocabIds.remove(vocabId);

      // ✅ Cập nhật Supabase: đánh dấu đã học
      await Supabase.instance.client
          .from('user_vocabulary_progress')
          .update({'is_learned': true})
          .match({
        'user_id': userId,
        'vocabulary_id': vocabId,
      });
    }
  }


  Future<void> fetchVocabulary() async {
    final response = await Supabase.instance.client
        .from('flashcard_words')
        .select()
        .eq('flashcard_id', widget.topicId);

    final data = response as List;

    vocabList = data.map((e) => Vocabulary.fromMap(e)).toList();
    vocabList.shuffle();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> nextQuestion() async {
    if (currentQuestionIndex < vocabList.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _submitted = false;
        _isCorrect = false;
        _answerController.clear();
      });
    } else {
      if (incorrectVocabIds.isNotEmpty) {
        // làm lại chỉ các từ sai
        vocabList = vocabList
            .where((v) => incorrectVocabIds.contains(v.id))
            .toList()
          ..shuffle();
        setState(() {
          currentQuestionIndex = 0;
          _submitted = false;
          _isCorrect = false;
          _answerController.clear();
        });
      } else {
        // ✅ kết thúc thật sự
        await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Hoàn thành!"),
          content: Text("Bạn đã làm đúng tất cả các từ."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
        );
        Navigator.pop(context);
      }
    }
  }
  @override
  void dispose() {
    _answerController.dispose();
    _markIncorrectAsUnlearned();
    super.dispose();
  }

  Future<void> _markIncorrectAsUnlearned() async {
    for (final vocabId in incorrectVocabIds) {
      await Supabase.instance.client
          .from('user_vocabulary_progress')
          .update({'is_learned': false})
          .match({
        'user_id': userId,
        'vocabulary_id': vocabId,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vocabList.isEmpty) {
      return Scaffold(
        body: Center(child: Text("Không có từ vựng nào trong chủ đề này.")),
      );
    }

    final currentVocab = vocabList[currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFCFEBFF), Color(0xFFC5E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(onNotificationTap: () {}),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () {
                      Navigator.pop(context); // dialog
                      Navigator.pop(context, true); // pop về main
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Flashcard Typing",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Question ${currentQuestionIndex + 1}/${vocabList.length}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Hint"),
                                        content: currentVocab.imageUrl != null && currentVocab.imageUrl!.isNotEmpty
                                            ? Image.network(
                                          currentVocab.imageUrl!,
                                          height: 180,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Text("Không thể tải ảnh"),
                                        )
                                            : Text("Không có hình ảnh"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Đóng"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline,
                                          color: Colors.red),
                                      SizedBox(width: 5),
                                      Text("Hint",
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text("The corresponding meaning of the word:",
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            Text(
                              currentVocab.meaning,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _answerController,
                              enabled: !_submitted,
                              decoration: InputDecoration(
                                hintText: "Type your answer here...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _submitted
                                ? Row(
                                    children: [
                                      Icon(
                                        _isCorrect
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: _isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          _isCorrect
                                              ? "Correct!"
                                              : "Wrong! Correct answer: ${currentVocab.englishWord}",
                                          style: TextStyle(
                                            color: _isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: _submitted
                                      ? Colors.green
                                      : Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    _submitted ? nextQuestion : checkAnswer,
                                child: Text(
                                  _submitted ? "Next Question" : "Submit",
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
