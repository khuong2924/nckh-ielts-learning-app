import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Vocabulary.dart';
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
  int selectedAnswer = -1;
  bool isLoading = true;
  String userId = '';
  Set<String> incorrectVocabIds = {};
  late List<Vocabulary> allVocabList; // chứa toàn bộ topic

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetch();
  }

  Future<void> _loadUserIdAndFetch() async {
    final box = await Hive.openBox('app_box');
    userId = box.get('user_id', defaultValue: '') ?? '';
    await fetchVocabulary();
  }

  Future<void> fetchVocabulary() async {
    final response = await Supabase.instance.client
        .from('flashcard_words')
        .select()
        .eq('flashcard_id', widget.topicId);

    final data = response as List;

    vocabList = data.map((e) => Vocabulary.fromMap(e)).toList();
    allVocabList = List.from(vocabList); // gán trước để tránh lỗi late

    if (vocabList.isNotEmpty) {
      vocabList.shuffle();
      loadQuestion(0);
    }

    setState(() => isLoading = false);
  }


  void loadQuestion(int index) {
    final currentVocab = vocabList[index];
    final correctAnswer = currentVocab.meaning;

    // Lấy tất cả meaning từ các từ khác trong topic (dù đã đúng hay chưa)
    List<String> wrongAnswers = allVocabList
        .where((e) => e.id != currentVocab.id)
        .map((e) => e.meaning)
        .toSet() // tránh trùng
        .toList();

    wrongAnswers.shuffle();

    // Chỉ lấy tối đa 3 đáp án sai để cộng với 1 đáp án đúng thành 4
    wrongAnswers = wrongAnswers.take(3).toList();

    answerOptions = [...wrongAnswers, correctAnswer];
    answerOptions.shuffle();

    correctAnswerIndex = answerOptions.indexOf(correctAnswer);
  }

  @override
  void dispose() {
    _updateIncorrectWords();
    super.dispose();
  }

  Future<void> _updateIncorrectWords() async {
    for (final vocabId in incorrectVocabIds) {
      await Supabase.instance.client
          .from('user_vocabulary_progress')
          .update({'is_learned': false})
          .match({'user_id': userId, 'vocabulary_id': vocabId});
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Flashcard Quiz",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Question ${currentQuestionIndex + 1}/${vocabList.length}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (currentVocab.imageUrl != null &&
                                  currentVocab.imageUrl!.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Hint"),
                                        content: Image.network(
                                          currentVocab.imageUrl!,
                                          height: 150,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Text("Không thể tải ảnh"),
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
                                      Icon(Icons.image, color: Colors.orange),
                                      SizedBox(width: 4),
                                      Text("Hint",
                                          style:
                                          TextStyle(color: Colors.orange)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "The corresponding meaning of the word:",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentVocab.englishWord,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: List.generate(answerOptions.length,
                                    (index) {
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
                                    onTap: () async {
                                      if (selectedAnswer == -1) {
                                        final vocabId = currentVocab.id;
                                        final isCorrect =
                                            index == correctAnswerIndex;

                                        if (isCorrect) {
                                          incorrectVocabIds.remove(vocabId);
                                          await Supabase.instance.client
                                              .from('user_vocabulary_progress')
                                              .update({'is_learned': true})
                                              .match({
                                            'user_id': userId,
                                            'vocabulary_id': vocabId,
                                          });
                                        } else {
                                          incorrectVocabIds.add(vocabId);
                                        }

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
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (currentQuestionIndex < vocabList.length - 1) {
                                  setState(() {
                                    currentQuestionIndex++;
                                    loadQuestion(currentQuestionIndex);
                                    selectedAnswer = -1;
                                  });
                                } else {
                                  // 🔁 Sau khi làm hết, kiểm tra có từ sai không
                                  if (incorrectVocabIds.isNotEmpty) {
                                    vocabList = allVocabList
                                        .where((v) => incorrectVocabIds.contains(v.id))
                                        .toList()
                                      ..shuffle();

                                    setState(() {
                                      currentQuestionIndex = 0;
                                      loadQuestion(currentQuestionIndex);
                                      selectedAnswer = -1;
                                    });
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Hoàn thành!"),
                                        content: Text("Bạn đã trả lời đúng tất cả các câu."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context); // đóng dialog
                                              Navigator.pop(context, true); // báo trang trước reload
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
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
