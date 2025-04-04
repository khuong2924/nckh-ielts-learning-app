import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class FlashcardTyping extends StatefulWidget {
  const FlashcardTyping({super.key});

  @override
  State<FlashcardTyping> createState() => _FlashcardTypingState();
}

class _FlashcardTypingState extends State<FlashcardTyping> {
  int _currentIndex = 1;
  final TextEditingController _answerController = TextEditingController();
  bool _isCorrect = false;
  bool _submitted = false;
  final String question = "Hello";
  final String correctAnswer = "Xin chào";

  void checkAnswer() {
    setState(() {
      _submitted = true;
      _isCorrect = _answerController.text.trim().toLowerCase() ==
          correctAnswer.toLowerCase();
    });
  }

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
              CustomAppBar(
                onNotificationTap: () {},
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
                                Text("Question 3/10",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                GestureDetector(
                                  onTap: () {},
                                  child: Row(
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
                            Text(
                              "The corresponding meaning of the word:",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              question,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _answerController,
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
                                      Text(
                                        _isCorrect
                                            ? "Correct!"
                                            : "Wrong! Correct answer: $correctAnswer",
                                        style: TextStyle(
                                          color: _isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox.shrink(),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: checkAnswer,
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
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
