import 'package:auth/presentation/components/FillInTheBlank.dart';
import 'package:auth/presentation/components/MultipleChoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth/presentation/service/SupabaseService.dart';

class ListeningTestPage extends StatefulWidget {
  final int testId;

  const ListeningTestPage({super.key, required this.testId});

  @override
  State<ListeningTestPage> createState() => _ListeningTestPageState();
}

class _ListeningTestPageState extends State<ListeningTestPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> _parts = [];
  Map<int, List<Map<String, dynamic>>> _questionsByPart = {};
  Map<int, String?> _selectedAnswers = {};
  int? _currentPlayingPartId;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchPartsAndQuestions();
  }

  Future<void> _fetchPartsAndQuestions() async {
    try {
      final parts = await _supabaseService.fetchPartsByTestId(widget.testId);
      setState(() {
        _parts = parts;
      });

      for (var part in parts) {
        final partId = part['id'];
        final questions = await _supabaseService.fetchQuestionsByPartId(partId);
        setState(() {
          _questionsByPart[partId] = questions;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching test data: ${e.toString()}')),
      );
    }
  }

  void _playPauseAudio(int partId, String audioUrl) async {
    if (_currentPlayingPartId == partId && _isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentPlayingPartId != null) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(UrlSource(audioUrl));
      setState(() {
        _currentPlayingPartId = partId;
      });
    }

    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final questionType = question['question_type'];
    final questionId = question['id'];
    final questionText = question['question_text'];

    if (questionType == 'multiple_choice') {
      return MultipleChoiceQuestion(
        questionText: questionText,
        choices: List<String>.from(question['choices']),
        onAnswerSelected: (answer) {
          setState(() {
            _selectedAnswers[questionId] = answer;
          });
        },
        selectedAnswer: _selectedAnswers[questionId],
      );
    } else if (questionType == 'fill_in_the_blank') {
      return FillInTheBlankQuestion(
        questionText: questionText,
        onAnswerSubmitted: (answer) {
          setState(() {
            _selectedAnswers[questionId] = answer;
          });
        },
      );
    }

    return Container(); // Placeholder for unsupported question types
  }

  Widget _buildPartWidget(Map<String, dynamic> part) {
    final partId = part['id'];
    final questions = _questionsByPart[partId] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              part['part_title'] ?? 'Part Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _playPauseAudio(partId, part['audio_url']),
              icon: Icon(_currentPlayingPartId == partId && _isAudioPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
              label: Text('Listen'),
            ),
            ...questions.map(_buildQuestionWidget).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswers() async {
    try {
      await _supabaseService.saveUserAnswers(widget.testId, _selectedAnswers);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your answers have been submitted!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answers: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Test'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _parts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _parts.length,
        itemBuilder: (context, index) {
          return _buildPartWidget(_parts[index]);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _submitAnswers,
          child: const Text('Submit Answers'),
        ),
      ),
    );
  }
}
