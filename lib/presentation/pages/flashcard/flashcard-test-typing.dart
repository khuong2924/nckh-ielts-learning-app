import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchVocabulary();
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

  void checkAnswer() {
    setState(() {
      _submitted = true;
      _isCorrect = _answerController.text.trim().toLowerCase() ==
          vocabList[currentQuestionIndex].vietnameseWord.toLowerCase();
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < vocabList.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _submitted = false;
        _isCorrect = false;
        _answerController.clear();
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Quiz Finished"),
          content: Text("You've reached the end of the quiz."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        ),
      );
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
                      Navigator.pop(context);
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
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentVocab.example ??
                                                  "Không có ví dụ",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 10),
                                            if (currentVocab.imageUrl != null &&
                                                currentVocab
                                                    .imageUrl!.isNotEmpty)
                                              Image.network(
                                                currentVocab.imageUrl!,
                                                height: 150,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Text(
                                                        "Không thể tải ảnh",
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                              )
                                            else
                                              const Text("Không có hình ảnh"),
                                          ],
                                        ),
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
                              currentVocab.englishWord,
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
                                              : "Wrong! Correct answer: ${currentVocab.vietnameseWord}",
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
