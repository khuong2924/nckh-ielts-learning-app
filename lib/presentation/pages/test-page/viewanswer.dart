import 'package:flutter/material.dart';
import 'dart:math' as math;

class ViewAnswersPage extends StatefulWidget {
  final List<Map<String, dynamic>> parts;
  final Map<int, Map<int, String>> userAnswersPerPart;
  final Map<int, List<Map<String, dynamic>>> partAnswers;

  const ViewAnswersPage({
    Key? key,
    required this.parts,
    required this.userAnswersPerPart,
    required this.partAnswers,
  }) : super(key: key);

  @override
  State<ViewAnswersPage> createState() => _ViewAnswersPageState();
}

class _ViewAnswersPageState extends State<ViewAnswersPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _parts;
  late Map<int, Map<int, String>> _userAnswersPerPart;
  late Map<int, List<Map<String, dynamic>>> _partAnswers;
  

  late AnimationController _animationController;
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // mock data
    _parts = widget.parts.isNotEmpty ? widget.parts : _getSampleParts();
    _userAnswersPerPart = widget.userAnswersPerPart.isNotEmpty ? widget.userAnswersPerPart : _getSampleUserAnswers();
    _partAnswers = widget.partAnswers.isNotEmpty ? widget.partAnswers : _getSamplePartAnswers();
    
    _tabController = TabController(length: _parts.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  List<Map<String, dynamic>> _getSampleParts() {
    return [
      {
        'id': 1,
        'part_title': 'Reading Passage 1',
        'part_description': 'Read the passage about climate change and answer questions 1-5.',
      },
      {
        'id': 2,
        'part_title': 'Reading Passage 2',
        'part_description': 'Read the passage about artificial intelligence and answer questions 6-10.',
      },
      {
        'id': 3,
        'part_title': 'Reading Passage 3',
        'part_description': 'Read the passage about marine biology and answer questions 11-15.',
      },
    ];
  }

  Map<int, Map<int, String>> _getSampleUserAnswers() {
    return {
      1: {1: 'A', 2: 'B', 3: 'C', 4: 'D', 5: 'A'},
      2: {6: 'B', 7: 'C', 8: 'A', 9: 'D', 10: 'B'},
      3: {11: 'C', 12: 'D', 13: 'A', 14: 'B', 15: 'C'},
    };
  }

  Map<int, List<Map<String, dynamic>>> _getSamplePartAnswers() {
    return {
      1: [
        {'question_number': 1, 'correct_answer': 'A', 'explanation': 'The passage states that global temperatures have risen by 1°C since pre-industrial times.'},
        {'question_number': 2, 'correct_answer': 'C', 'explanation': 'The author mentions that deforestation contributes to 15% of carbon emissions.'},
        {'question_number': 3, 'correct_answer': 'C', 'explanation': 'The passage indicates that renewable energy sources are becoming more cost-effective.'},
        {'question_number': 4, 'correct_answer': 'B', 'explanation': 'According to the text, sea levels are projected to rise by 0.5-1.2 meters by 2100.'},
        {'question_number': 5, 'correct_answer': 'A', 'explanation': 'The passage concludes that immediate action is necessary to mitigate climate change.'},
      ],
      2: [
        {'question_number': 6, 'correct_answer': 'B', 'explanation': 'The text defines AI as the simulation of human intelligence by machines.'},
        {'question_number': 7, 'correct_answer': 'C', 'explanation': 'The passage mentions that machine learning is a subset of AI focused on pattern recognition.'},
        {'question_number': 8, 'correct_answer': 'A', 'explanation': 'According to the passage, neural networks are modeled after the human brain.'},
        {'question_number': 9, 'correct_answer': 'D', 'explanation': 'The text states that AI applications include healthcare, finance, and transportation.'},
        {'question_number': 10, 'correct_answer': 'B', 'explanation': 'The passage discusses ethical concerns related to AI, including privacy and bias.'},
      ],
      3: [
        {'question_number': 11, 'correct_answer': 'C', 'explanation': 'The passage states that oceans cover 71% of Earth\'s surface.'},
        {'question_number': 12, 'correct_answer': 'D', 'explanation': 'According to the text, coral reefs support 25% of marine species.'},
        {'question_number': 13, 'correct_answer': 'A', 'explanation': 'The passage mentions that ocean acidification is caused by increased CO2 absorption.'},
        {'question_number': 14, 'correct_answer': 'B', 'explanation': 'The text indicates that overfishing has depleted 33% of global fish stocks.'},
        {'question_number': 15, 'correct_answer': 'C', 'explanation': 'The passage concludes that marine conservation efforts are essential for ecosystem health.'},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFCFEBFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _parts.map((part) => _buildPartContent(part)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0067AC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Your Answers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF0067AC),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFFE33629),
        indicatorWeight: 3,
        tabs: _parts.map((part) {
          return Tab(
            child: Text(
              'Passage ${part['id']}',
              style: const TextStyle(
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPartContent(Map<String, dynamic> part) {
    final partId = part['id'];
    final answers = _partAnswers[partId] ?? [];
    final userAnswers = _userAnswersPerPart[partId] ?? {};
    
   
    int correctCount = 0;
    for (var answer in answers) {
      final questionNumber = answer['question_number'];
      final correctAnswer = answer['correct_answer'];
      final userAnswer = userAnswers[questionNumber];
      if (userAnswer == correctAnswer) {
        correctCount++;
      }
    }
    
    final scorePercentage = answers.isEmpty ? 0 : (correctCount / answers.length) * 100;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildScoreCard(scorePercentage.toDouble(), correctCount, answers.length),
        const SizedBox(height: 16),
        _buildPartInfoCard(part),
        const SizedBox(height: 16),
        ...answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          return _buildQuestionCard(answer, userAnswers, index);
        }).toList(),
      ],
    );
  }

  Widget _buildScoreCard(double scorePercentage, int correctCount, int totalCount) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4681DA),
              Color(0xFF0067AC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Your Score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jost',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: scorePercentage / 100),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          
                          Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreDetail(Icons.check_circle, '$correctCount Correct', Colors.green.shade300),
                    const SizedBox(height: 8),
                    _buildScoreDetail(Icons.cancel, '${totalCount - correctCount} Incorrect', Colors.red.shade300),
                    const SizedBox(height: 8),
                    _buildScoreDetail(Icons.assignment, '$totalCount Total Questions', Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontFamily: 'Jost',
          ),
        ),
      ],
    );
  }

  Widget _buildPartInfoCard(Map<String, dynamic> part) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFE6F4FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              part['part_title'] ?? 'Reading Passage',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
                fontFamily: 'Jost',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              part['part_description'] ?? 'No description available',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Jost',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> answer, Map<int, String> userAnswers, int index) {
    final questionNumber = answer['question_number'];
    final userAnswer = userAnswers[questionNumber] ?? 'No answer';
    final correctAnswer = answer['correct_answer'] ?? 'No correct answer';
    final explanation = answer['explanation'] ?? 'No explanation available';
    final isCorrect = userAnswer == correctAnswer;
    
    final isExpanded = _expandedIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(
        bottom: 16,
        top: 0,
      ),
      child: Card(
        elevation: isExpanded ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isCorrect ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // Question header
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_expandedIndex == index) {
                        _expandedIndex = -1;
                      } else {
                        _expandedIndex = index;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isExpanded ? 0 : 15),
                        bottomRight: Radius.circular(isExpanded ? 0 : 15),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Question number circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCorrect ? Colors.green : Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              questionNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Answer information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Your Answer:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                  _buildAnswerBadge(userAnswer, isCorrect),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Correct Answer:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                  _buildAnswerBadge(correctAnswer, true),
                                ],
                              ),
                            ],
                          ),
                        ),
                     
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isExpanded ? null : 0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF0067AC),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Explanation:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0067AC),
                                    fontFamily: 'Jost',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F9FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFD0E5FF),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                explanation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontFamily: 'Jost',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerBadge(String answer, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        answer,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Jost',
        ),
      ),
    );
  }
}
