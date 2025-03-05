import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = "https://api.mistral.ai/v1/chat/completions";
const String apiKey = "3MVsD1vcXAOTl1qjDx42z2wpLS2KUDvc";

class IeltsFeedbackPage extends StatefulWidget {
  final List<Map<String, String>> submissions;

  const IeltsFeedbackPage({Key? key, required this.submissions}) : super(key: key);

  @override
  _IeltsFeedbackScreenState createState() => _IeltsFeedbackScreenState();
}

class _IeltsFeedbackScreenState extends State<IeltsFeedbackPage> {
  double? ieltsScore;
  List<String> grammarSuggestions = [];
  String summary = "";
  String overallFeedback = "";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchIeltsFeedback();
  }

  Future<void> fetchIeltsFeedback() async {
    try {
      // 📝 Tạo nội dung gửi lên API Mistral
      String userPrompt = '''
      You are an IELTS examiner. Please analyze the following two IELTS Writing Task responses and provide structured feedback. Your response should strictly follow this format:
      ---
**Overall IELTS Writing Band Score:** (Provide a single band score considering both essays, knowing those are two different tasks for an IELTS Writing Test.)

**Grammar Suggestions:**  
(List the grammar mistakes for each essay separately.)

**Summary of Both Essays:**  
(Summarize both essays in 2-3 sentences each.)

**Overall Feedback:**  
(Give an overall evaluation of the writing, including strengths and areas for improvement.)
---

### Essay 1:
Task: {Insert Task 1 description here}  
Answer: {Insert Task 1 response here}

### Essay 2:
Task: {Insert Task 2 description here}  
Answer: {Insert Task 2 response here}

Please ensure that each section is clearly labeled as shown in the format above.
''';
      for (var essay in widget.submissions) {
        if (essay['user_answer']!.length < 10) {
          print("Warning: One of the essays is too short and may not be analyzed properly.");
        }
      }

      // 🛠 Sửa lỗi JSON request
      final Map<String, dynamic> requestBody = {
        "model": "mistral-medium", // ✅ Kiểm tra lại model hợp lệ
        "messages": [
          {"role": "system", "content": "You are an IELTS examiner. Evaluate the following essay."},
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
        body: jsonEncode(requestBody), // ✅ Đảm bảo JSON đúng
      );

      print("📢 API Status Code: ${response.statusCode}");
      print("🔥 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['choices'][0]['message']['content'] ?? "";

        RegExp scoreRegex = RegExp(
            r"overall IELTS Writing Band Score[:\s]*([\d.]+)",
            caseSensitive: false
        );

        RegExp feedbackRegex = RegExp(
            r"Overall feedback:\s*(.*?)(?=(Grammar suggestions|$))",
            caseSensitive: false,
            dotAll: true
        );

        RegExp summaryRegex = RegExp(
            r"Summary of both essays:\s*(.*?)(?=(Overall feedback|Grammar suggestions|$))",
            caseSensitive: false,
            dotAll: true
        );

        RegExp grammarRegex = RegExp(
            r"Grammar suggestions:\s*(.*?)(?=(Summary|$))",
            caseSensitive: false,
            dotAll: true
        );



        setState(() {
          ieltsScore = double.tryParse(scoreRegex.firstMatch(aiResponse)?.group(1) ?? "") ?? null;
          grammarSuggestions = grammarRegex.firstMatch(aiResponse)?.group(1)?.split("\n") ?? [];
          summary = summaryRegex.firstMatch(aiResponse)?.group(1) ?? "No summary available.";
          overallFeedback = feedbackRegex.firstMatch(aiResponse)?.group(1) ?? "No feedback available.";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "❌ API Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "⚠️ Exception: ${e.toString()}";
      });
    }
  }


  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(icon, color: color),
              title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(content, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        leading: Icon(Icons.spellcheck, color: Colors.orange),
        title: Text("Grammar Suggestions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        children: grammarSuggestions.isNotEmpty
            ? grammarSuggestions.map((suggestion) => ListTile(title: Text(suggestion))).toList()
            : [Padding(padding: EdgeInsets.all(16), child: Text("No suggestions"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IELTS Feedback')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
          : ListView(
        children: [
          _buildSection(
            "IELTS Score",
            ieltsScore != null ? ieltsScore.toString() : "Not determined",
            Icons.score,
            Colors.blue,
          ),
          _buildGrammarSection(),
          _buildSection("Essay Summary", summary, Icons.book, Colors.green),
          _buildSection("Overall Feedback", overallFeedback, Icons.feedback, Colors.purple),
        ],
      ),
    );
  }
}
