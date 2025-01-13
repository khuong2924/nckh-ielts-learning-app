import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/presentation/model/TestCard.dart'; // Import TestCard
import 'package:auth/presentation/service/SupabaseService.dart';

class ListeningTestPage extends StatefulWidget {
  const ListeningTestPage({super.key});

  @override
  State<ListeningTestPage> createState() => _ListeningTestPageState();
}

class _ListeningTestPageState extends State<ListeningTestPage> {
  int _currentIndex = 0;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final List<TextEditingController> answerControllers =
  List.generate(10, (index) => TextEditingController());
  String? selectedAnswer9;
  String? selectedAnswer10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {
                // Xử lý notification
              },
            ),
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildInstruction1(),
                      _buildAudioPlayer(),

                      _buildQuestions1to5(),
                      _buildQuestions6to8(),
                      _buildQuestion9(),
                      _buildQuestion10(),
                      _buildSubmitButton(),
                    ],
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
        );

  }



  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 54,
            height: 49,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 49,
            decoration: ShapeDecoration(
              color: Color(0xFF0067AC),
              shape: OvalBorder(
                side: BorderSide(width: 1, color: Color(0xFF773287)),
              ),
            ),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset('lib/icons/ic-back.svg'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Listening',
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

  Widget _buildAudioPlayer() {
    String formatTime(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0x750067AC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                    // Handle audio playback
                  },
                ),
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    // Handle seeking
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... Continue with previous widgets (_buildInstructions, _buildQuestions1to5, etc.)

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          // Handle submit
          _showSubmitDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0067AC),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Test'),
        content: Text('Are you sure you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle final submission
              Navigator.pop(context);
              // Navigate to results page
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction1() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To listen now, click the speaker icon:',
            style: TextStyle(
              color: Color(0xFFF15327),
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildInstruction2() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            'Complete the information below, write no more than one word or a number for each answer.',
            style: TextStyle(
              color: Color(0xFF404040),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildQuestions1to5() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Question 1 - 5'),
          _buildInstruction2(),
          _buildInfoTable(),
          const SizedBox(height: 10),
          ...List.generate(5, (index) => _buildAnswerField(index + 1)),
        ],
      ),
    );
  }

  Widget _buildAnswerField(int questionNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextField(
        controller: answerControllers[questionNumber - 1],
        decoration: InputDecoration(
          labelText: 'Answer $questionNumber',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildInfoTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              _buildTableCell('Street'),
              _buildTableCell('Bridge Street'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Owner'),
              _buildTableCell('(1)... Smith'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('(2)...'),
              _buildTableCell('0912476321'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Included'),
              _buildTableCell('(3)..., heat,(4)...'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Near'),
              _buildTableCell('Central HighSchool and (5)...'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF404040),
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildQuestions6to8() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Question 6 - 8'),
          _buildQuestion(
            'What did the citizens around there think that should be enhance?',
            [
              'public transportation in overall',
              'the living standards',
              'noise pollution',
              'heat',
              'the lack of entertainment activities',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion9() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Question 9'),
          _buildQuestion(
            'What did Anderson think about her surroundings?',
            [
              'peaceful',
              'she hate living here',
              'abcdefgh',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion10() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Question 10'),
          _buildQuestion(
            'What did Anderson think about her surroundings?',
            [
              'peaceful',
              'she hate living here',
              'abcdefgh',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF1D1B20),
          fontSize: 22,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            color: Color(0xFF404040),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) => _buildOptionItem(option)).toList(),
      ],
    );
  }

  Widget _buildOptionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            child: Radio(
              value: text,
              groupValue: null,
              onChanged: (value) {
                // Handle radio selection
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Color(0xFF404040),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}