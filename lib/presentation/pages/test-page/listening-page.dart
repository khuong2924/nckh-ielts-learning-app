import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/presentation/components/FillInTheBlank.dart'; // Nếu bạn đã tạo component này

class ListeningTestPage extends StatefulWidget {
  final int testId;

  const ListeningTestPage({super.key, required this.testId});

  @override
  State<ListeningTestPage> createState() => _ListeningTestPageState();
}

class _ListeningTestPageState extends State<ListeningTestPage> {
  late Future<List<Map<String, dynamic>>> partsData;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late String userId;
  Map<int, List<Map<String, dynamic>>> selectedAnswers = {}; // Lưu câu trả lời cho từng phần

  @override
  void initState() {
    super.initState();
    _loadUserId();  // Load the userId from SharedPreferences
    partsData = fetchListeningParts(widget.testId);
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';  // Retrieve the userId from SharedPreferences
    });
  }

  Future<List<Map<String, dynamic>>> fetchListeningParts(int testId) async {
    try {
      final response = await Supabase.instance.client
          .from('listening_parts')
          .select()
          .eq('test_id', testId)
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw Exception('Error fetching parts: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching parts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAnswers(int partId) async {
    try {
      final response = await Supabase.instance.client
          .from('answers')
          .select()
          .eq('part_id', partId)
          .order('question_number', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw Exception('Error fetching answers for part: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching answers: $e');
    }
  }

  Future<void> _submitAnswers(Map<int, List<Map<String, dynamic>>> selectedAnswers) async {
    if (selectedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user_answers')
          .upsert(selectedAnswers.values.expand((x) => x).toList());
      if (response.error != null) {
        throw response.error!;
      }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listening Test')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: partsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No parts available'));
          }

          final parts = snapshot.data!;

          return ListView.builder(
            itemCount: parts.length,
            itemBuilder: (context, index) {
              final part = parts[index];
              return PartWidget(
                part: part,
                fetchAnswers: fetchAnswers,
                audioPlayer: _audioPlayer,
                userId: userId,
                selectedAnswers: selectedAnswers,
                onAnswerSubmitted: (partId, answer) {
                  setState(() {
                    if (!selectedAnswers.containsKey(partId)) {
                      selectedAnswers[partId] = [];
                    }
                    selectedAnswers[partId]!.add(answer);
                  });
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            _submitAnswers(selectedAnswers);
          },
          child: const Text('Submit Answers'),
        ),
      ),
    );
  }
}

class PartWidget extends StatefulWidget {
  final Map<String, dynamic> part;
  final Future<List<Map<String, dynamic>>> Function(int) fetchAnswers;
  final AudioPlayer audioPlayer;
  final String userId;
  final Map<int, List<Map<String, dynamic>>> selectedAnswers;
  final Function(int, Map<String, dynamic>) onAnswerSubmitted;

  PartWidget({
    required this.part,
    required this.fetchAnswers,
    required this.audioPlayer,
    required this.userId,
    required this.selectedAnswers,
    required this.onAnswerSubmitted,
  });

  @override
  _PartWidgetState createState() => _PartWidgetState();
}

class _PartWidgetState extends State<PartWidget> {
  late Future<List<Map<String, dynamic>>> answersData;
  bool _hasPlayed = false;
  Map<int, String> userAnswers = {}; // Store user answers locally

  @override
  void initState() {
    super.initState();
    answersData = widget.fetchAnswers(widget.part['id']);
  }

  void _playAudio() async {
    if (widget.part['audio_url'] != null && widget.part['audio_url'].isNotEmpty && !_hasPlayed) {
      await widget.audioPlayer.play(widget.part['audio_url']);
      setState(() {
        _hasPlayed = true; // Mark that the audio has played
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.part['part_title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(widget.part['part_description'] ?? 'No description'),
            SizedBox(height: 10),
            widget.part['audio_url'] != null
                ? IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: Colors.green,
              ),
              onPressed: _playAudio,
            )
                : Container(),
            SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: answersData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error loading answers: ${snapshot.error}');
                }

                final answers = snapshot.data!;
                return Column(
                  children: List.generate(answers.length, (index) {
                    final answer = answers[index];
                    String initialAnswer = widget.selectedAnswers[widget.part['id']]
                        ?.firstWhere(
                          (item) => item['question_number'] == answer['question_number'],
                      orElse: () => {'user_answer': ''},
                    )['user_answer'] ??
                        '';

                    return FillInTheBlankQuestion(
                      questionText: 'Question ${answer['question_number']}',
                      initialAnswer: userAnswers[answer['question_number']] ?? initialAnswer,
                      onAnswerSubmitted: (userAnswer) {
                        setState(() {
                          userAnswers[answer['question_number']] = userAnswer!; // Update local state
                        });
                        widget.onAnswerSubmitted(
                          widget.part['id'],
                          {
                            'user_id': widget.userId,
                            'part_id': widget.part['id'],
                            'question_number': answer['question_number'],
                            'user_answer': userAnswer,
                            'is_correct': false, // Placeholder logic for answer validation
                          },
                        );
                      },
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}