import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class FlashCardQuiz extends StatefulWidget {
  const FlashCardQuiz({super.key});

  @override
  State<FlashCardQuiz> createState() => _FlashCardQuizState();
}

class _FlashCardQuizState extends State<FlashCardQuiz> {
  int _currentIndex = 1;
  int selectedAnswer = -1;
  int correctAnswer = 3;

  List<String> answers = [
    "A. Xin chào",
    "B. Tạm biệt",
    "C. Cảm ơn",
    "D. Xin chào"
  ];

  @override
  Widget build(BuildContext context) {
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
                              const Text(
                                "Question 3/10",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Xử lý Hint
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
                            style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold,),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Hello",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: List.generate(answers.length, (index) {
                              Color borderColor = Colors.blue;
                              Color fillColor = Colors.white;
                              Color textColor = Colors.black;

                              if (selectedAnswer != -1) {
                                if (index == correctAnswer) {
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
                                  setState(() {
                                    selectedAnswer = index;
                                  });
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
                                        answers[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      Icon(
                                        selectedAnswer == index
                                            ? (index == correctAnswer
                                                ? Icons.check_circle
                                                : Icons.cancel)
                                            : Icons.circle_outlined,
                                        color: textColor,
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
                                  selectedAnswer =
                                      -1; // Reset lựa chọn cho câu tiếp theo
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
