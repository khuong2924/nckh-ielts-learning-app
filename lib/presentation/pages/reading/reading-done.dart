import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth/presentation/pages/test-page/viewanswer.dart';

import '../main-page/sample-test-home-page.dart';
class ReadingDone extends StatefulWidget {
  final double score;
  final int timeTaken;
  final Map<int, int> correctAnswersPerPart;
  final Map<int, Map<int, String>> userAnswers;
  final List<Map<String, dynamic>> parts; // Add this
  final Map<int, List<Map<String, dynamic>>> partAnswers; // Add this

  const ReadingDone({
    Key? key,
    required this.score,
    required this.timeTaken,
    required this.correctAnswersPerPart,
    required this.userAnswers,
    required this.parts,
    required this.partAnswers,
  }) : super(key: key);

  @override
  State<ReadingDone> createState() => _ReadingDoneState();
}

class _ReadingDoneState extends State<ReadingDone> {
  int _currentIndex = 0;

  double _calculateProgress(int part) {
    int correctAnswers = widget.correctAnswersPerPart[part] ?? 0;
    int totalQuestions = widget.userAnswers.length; // Assuming userAnswers contains answers for all parts
    return totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
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
                // Handle notification
              },
            ),
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCongrats(),
                    const SizedBox(height: 10),
                    _buildComment(),
                    const SizedBox(height: 20),
                    _buildBand(widget.score.toString()),
                    const SizedBox(height: 20),
                    _buildRoundContainer(),
                    const SizedBox(height: 20),
                    _buildButtons(),
                    const SizedBox(height: 20),
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
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'lib/icons/ic-close.svg',
              width: 24,
              height: 24,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Complete',
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

  Widget _buildCongrats() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'CONGRATS',
        style: const TextStyle(
          color: Color(0xFFE33629),
          fontSize: 40,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildComment() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'You Just Completed',
        style: const TextStyle(
          color: Color(0xFFE0067AC),
          fontSize: 14,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBand(String band) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4681DA).withOpacity(0.4),
            Color(0xFFE33629).withOpacity(0.4),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4681DA).withOpacity(0.4),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 120),
            child: Text(
              'Band',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                band,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundContainer() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF4681DA).withOpacity(0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgress('1', _calculateProgress(1)),
                      _buildProgress('2', _calculateProgress(2)),
                      _buildProgress('3', _calculateProgress(3)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(String numberPart, double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6.0,
                backgroundColor: Color(0xFFE33629).withOpacity(0.4),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE33629)),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%', // Display percentage
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Part $numberPart',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Điều hướng đến ComplaintPage
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4681DA).withOpacity(0.69),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: const Text(
            'Exit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewAnswersPage(
                  parts: widget.parts, // Pass the actual parts data
                  userAnswersPerPart: widget.userAnswers, // Pass user answers
                  partAnswers: widget.partAnswers, // Pass the correct answers

                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0067AC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: const Text(
            'View Answer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}