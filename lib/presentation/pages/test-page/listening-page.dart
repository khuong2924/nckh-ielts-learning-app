import 'package:auth/presentation/model/TestCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListeningTestPage extends StatefulWidget {
  const ListeningTestPage({super.key, required TestCard test});

  @override
  State<ListeningTestPage> createState() => _ListeningTestPageState();
}

class _ListeningTestPageState extends State<ListeningTestPage> {
  int _currentIndex = 0;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final Map<int, String?> _selectedAnswers = {}; // Lưu câu trả lời
  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();  // Fetch questions from Supabase
    audioPlayer.onDurationChanged.listen(_onAudioDurationChanged);
    audioPlayer.onPositionChanged.listen(_onAudioPositionChanged);
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await Supabase.instance.client
          .from('listening_questions')
          .select('*');

      setState(() {
        _questions = response as List<dynamic>;
      });
    } on PostgrestException catch (e) {
      print('Error fetching questions: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching questions: $e');
    }
  }

  void _playPauseAudio(String audioUrl) async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      // Use UrlSource to create a Source object from the URL
      await audioPlayer.play(UrlSource(audioUrl));
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _onAudioPositionChanged(Duration position) {
    setState(() {
      this.position = position;
    });
  }

  void _onAudioDurationChanged(Duration duration) {
    setState(() {
      this.duration = duration;
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
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
            'Listening Test',
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

  Widget _buildAudioPlayer(String audioUrl) {
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
                    _playPauseAudio(audioUrl);
                  },
                ),
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    await audioPlayer.seek(Duration(seconds: value.toInt()));
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

  Widget _buildQuestions() {
    if (_questions.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _questions.map((question) {
          return _buildQuestionWidget(question);
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question_text'] ?? 'No question text',
            style: TextStyle(
              color: Color(0xFF404040),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ...question['choices'].map<Widget>((option) {
            return _buildOptionItem(option, question['id']);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String text, int questionId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Radio<String>(
            value: text,
            groupValue: _selectedAnswers[questionId],
            onChanged: (value) {
              setState(() {
                _selectedAnswers[questionId] = value;
              });
            },
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
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
              Navigator.pop(context);
              _submitAnswers();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitAnswers() {
    // Gửi câu trả lời lên Supabase hoặc xử lý điểm số ở đây
    print(_selectedAnswers);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstruction1(),
                      _buildAudioPlayer("https://ojjtdegibiythbrqhdkg.supabase.co/storage/v1/object/public/NCKH/Track-1.mp3?t=2025-01-17T19%3A47%3A34.967Z"),
                      _buildQuestions(),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
