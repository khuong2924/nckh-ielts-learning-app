import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Vocabulary.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlashCardQuiz extends StatefulWidget {
  final String topicId;

  const FlashCardQuiz({super.key, required this.topicId});

  @override
  State<FlashCardQuiz> createState() => _FlashCardQuizState();
}

class _FlashCardQuizState extends State<FlashCardQuiz> {
  int _currentIndex = 1;
  List<Vocabulary> vocabList = [];
  int currentQuestionIndex = 0;
  List<String> answerOptions = [];
  int correctAnswerIndex = -1;
  bool isLoading = true;
  int selectedAnswer = -1;
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

    if (vocabList.isNotEmpty) {
      vocabList.shuffle();
      loadQuestion(0);
    }

    setState(() {
      isLoading = false;
    });
  }

  void loadQuestion(int index) {
    final currentVocab = vocabList[index];
    final correctAnswer = currentVocab.vietnameseWord;

    List<String> wrongAnswers = vocabList
        .where((e) => e.id != currentVocab.id)
        .map((e) => e.vietnameseWord)
        .toList();
    wrongAnswers.shuffle();
    wrongAnswers = wrongAnswers.take(3).toList();

    answerOptions = [...wrongAnswers, correctAnswer];
    answerOptions.shuffle();
    correctAnswerIndex = answerOptions.indexOf(correctAnswer);
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
              // Header cố định
              CustomAppBar(
                onNotificationTap: () {
                  // Xử lý thông báo
                },
              ),
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
                    "Flashcard Quiz",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Nội dung Flashcard Quiz
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // Số câu hỏi và Hint
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Question ${currentQuestionIndex + 1}/${vocabList.length}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final vocab = vocabList[currentQuestionIndex];

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Hint"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              vocab.example ?? "Không có ví dụ",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 10),
                                            if (vocab.imageUrl != null &&
                                                vocab.imageUrl!.isNotEmpty)
                                              Image.network(
                                                vocab.imageUrl!,
                                                height: 150,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Text(
                                                  "Không thể tải ảnh",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
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
                                      );
                                    },
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.help_outline, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text("Hint",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Text(
                            "The corresponding meaning of the word:",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            vocabList[currentQuestionIndex].englishWord,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Column(
                            children:
                                List.generate(answerOptions.length, (index) {
                              Color borderColor = Colors.blue;
                              Color fillColor = Colors.white;
                              Color textColor = Colors.black;

                              if (selectedAnswer != -1) {
                                if (index == correctAnswerIndex) {
                                  fillColor = Colors.green[100]!;
                                  borderColor = Colors.green;
                                  textColor = Colors.green;
                                } else if (index == selectedAnswer) {
                                  fillColor = Colors.red[100]!;
                                  borderColor = Colors.red;
                                  textColor = Colors.red;
                                }
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (selectedAnswer == -1) {
                                    setState(() {
                                      selectedAnswer = index;
                                    });
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: borderColor, width: 2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        answerOptions[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      Icon(
                                        selectedAnswer == -1
                                            ? Icons.circle_outlined
                                            : (index == correctAnswerIndex
                                                ? Icons.check_circle
                                                : (index == selectedAnswer
                                                    ? Icons.cancel
                                                    : Icons.circle_outlined)),
                                        color: selectedAnswer == -1
                                            ? Colors.grey
                                            : (index == correctAnswerIndex
                                                ? Colors.green
                                                : (index == selectedAnswer
                                                    ? Colors.red
                                                    : Colors.grey)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // Nút Next Question
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (currentQuestionIndex <
                                      vocabList.length - 1) {
                                    currentQuestionIndex++;
                                    loadQuestion(currentQuestionIndex);
                                    selectedAnswer = -1;
                                  } else {
                                    // Hết câu hỏi – bạn có thể điều hướng sang màn hình kết quả hoặc hiển thị thông báo
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Quiz Finished"),
                                        content: Text(
                                            "You've reached the end of the quiz."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(
                                                  context); // hoặc reset lại quiz
                                            },
                                            child: Text("OK"),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Next Question",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Navigation giữ nguyên
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
