import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

const String apiUrl = "https://api.mistral.ai/v1/chat/completions";
const String apiKey = "3MVsD1vcXAOTl1qjDx42z2wpLS2KUDvc"; // Replace with your actual API key

class IeltsFeedbackPage extends StatefulWidget {
  final List<Map<String, String>> submissions;

  const IeltsFeedbackPage({Key? key, required this.submissions}) : super(key: key);

  @override
  _IeltsFeedbackScreenState createState() => _IeltsFeedbackScreenState();
}

class _IeltsFeedbackScreenState extends State<IeltsFeedbackPage> {
  String processedResponse = "";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchIeltsFeedback();
  }

  Future<void> fetchIeltsFeedback() async {
    try {
      String task1Content = widget.submissions.firstWhere((e) => e['title'] == 'Task 1')['content'] ?? '';
      String task2Content = widget.submissions.firstWhere((e) => e['title'] == 'Task 2')['content'] ?? '';

      String userPrompt = '''
You are an experienced IELTS examiner. Analyze the following IELTS Writing essays and give detailed and structured feedback.

Instructions:
- Mark all spelling or grammatical mistakes in **bold** or ~~strikethrough~~ if applicable.
- Give corrections right after the mistake, e.g., "**their** (should be *there*)".
- Structure your response with clear sections:
  1. **Overall IELTS Band Score** (30% Task 1 + 70% Task 2).
  2. **Grammar & Spelling Issues** (list all issues with suggested corrections).
  3. **Summary of Both Essays**.
  4. **Feedback on Coherence, Cohesion, Lexical Resource, and Grammatical Range and Accuracy**.

Essay Task 1:
$task1Content

Essay Task 2:
$task2Content
''';

      final Map<String, dynamic> requestBody = {
        "model": "mistral-medium",
        "messages": [
          {"role": "system", "content": "You are an IELTS examiner. Evaluate the following IELTS essays."},
          {"role": "user", "content": userPrompt}
        ],
        "temperature": 0.7
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['choices']?[0]['message']?['content'] ?? "";

        setState(() {
          processedResponse = aiResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "API Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IELTS Feedback')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(
          data: processedResponse,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(fontSize: 16),
            strong: const TextStyle(color: Colors.redAccent),
            em: const TextStyle(color: Colors.blueAccent),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
