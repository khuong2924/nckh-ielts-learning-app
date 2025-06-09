import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String apiUrl = "https://api.mistral.ai/v1/chat/completions";
final String apiKey = dotenv.env['MISTRAL_API_KEY'] ?? '';

class IeltsFeedbackPage extends StatefulWidget {
  final List<Map<String, String>> submissions;
  final int elapsedTime;
  final int testId; // ✅ thêm dòng này
  final String? cachedComment;

  const IeltsFeedbackPage({
    Key? key,
    required this.submissions,
    required this.elapsedTime,
    required this.testId, // ✅ thêm dòng này
    this.cachedComment,
  }) : super(key: key);

  @override
  State<IeltsFeedbackPage> createState() => _IeltsFeedbackPageState();
}


class _IeltsFeedbackPageState extends State<IeltsFeedbackPage> {
  final Map<String, String> sections = {
    "Overview & Scores": "",
    "Part 1: Band Score & Overview": "",
    "Part 2: Error Analysis & Corrections": "",
    "Part 3: Rewritten Essay (User Ideas)": "",
    "Part 4: Sample Band 8 Essay": "",
  };

  bool isLoading = true;
  String errorMessage = "";
  late int elapsedTime;

  @override
  void initState() {
    super.initState();
    if (widget.cachedComment != null && widget.cachedComment!.isNotEmpty) {
      _loadFromCache(widget.cachedComment!);
    } else {
      elapsedTime = widget.elapsedTime;
      fetchFeedback();
    }
  }
  void _loadFromCache(String content) {
    sections["Overview & Scores"] = _extractIntro(content);
    sections["Part 1: Band Score & Overview"] = _extractSection(content, 'Part 1: Band Score & Overview', content);
    sections["Part 2: Error Analysis & Corrections"] = _extractSection(content, 'Part 2: Error Analysis & Corrections', content);
    sections["Part 3: Rewritten Essay (User Ideas)"] = _extractSection(content, 'Part 3: Rewritten Essay', content);
    sections["Part 4: Sample Band 8 Essay"] = _extractSection(content, 'Part 4: Sample Band 8 Essay', content);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchFeedback() async {
    try {
      final task1 = widget.submissions.length > 0 ? widget.submissions[0] : {};
      final task2 = widget.submissions.length > 1 ? widget.submissions[1] : {};

      final description1 = (task1['task_description'] ?? '').toString();
      final description2 = (task2['task_description'] ?? '').toString();
      final content1 = (task1['user_answer'] ?? '').toString();
      final content2 = (task2['user_answer'] ?? '').toString();

      final prompt = '''
You are an IELTS Writing examiner. Please analyze the two essays below.

Format your answer in **Markdown** and divide your response into 4 clear sections with the following titles using `###` headings:

At the top, before the sections, include:

- **Overall Writing Band Score**: (30% Task 1 + 70% Task 2)
- **IELTS Criteria Table**:

| Criteria                           | Task 1 | Task 2 |
|-----------------------------------|--------|--------|
| Task Response (TR)                | X.X    | X.X    |
| Coherence and Cohesion (CC)       | X.X    | X.X    |
| Lexical Resource (LR)             | X.X    | X.X    |
| Grammatical Range & Accuracy (GRA)| X.X    | X.X    |

Then continue with the 4 sections:

### Part 1: Band Score & Overview  
- Provide a band score for each task (e.g. Essay Task 1: Band 7).  
- Summarize the quality of each essay in terms of clarity, structure, and task response.

### Part 2: Error Analysis & Corrections  
- For each task, list grammar/spelling/vocabulary mistakes.  
- Give corrections with suggestions, example:  
  "**their** (should be *there*)"

### Part 3: Rewritten Essay (User Ideas)  
- Rewrite each task using the user's original ideas, but improve grammar and coherence.

### Part 4: Sample Band 8 Essay  
- Write a model answer for each task, assuming ideal coherence, lexical resource, and grammar.

---

### 📝 Essay Task 1:
**Description:** $description1  
**User's Answer:**  
$content1

---

### 📝 Essay Task 2:
**Description:** $description2  
**User's Answer:**  
$content2
''';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "mistral-medium",
          "messages": [
            {
              "role": "system",
              "content": "You are a strict and structured IELTS writing examiner."
            },
            {
              "role": "user",
              "content": prompt,
            },
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]['message']?['content'] ?? '';

        print("DEBUG: Raw AI response:\n$content\n");

        // Lưu phản hồi vào Supabase (test_results)
        final box = await Hive.openBox('user_info');
        final userId = box.get('user_id', defaultValue: '');
        final testId = widget.submissions.length == 2 ?  // lấy testId từ phần đầu
        (widget.submissions[0]['test_id'] ?? '0') : '0';

        await Supabase.instance.client.from('test_results').insert({
          'user_id': userId,
          'test_id': widget.testId,
          'score': _extractOverallScore(content),
          'completed_at': DateTime.now().toIso8601String(),
          'total_questions': 2,
          'time': widget.elapsedTime,
          'comment': content,
        });

        // Phân tích nội dung theo từng phần
        sections["Overview & Scores"] = _extractIntro(content);
        sections["Part 1: Band Score & Overview"] = _extractSection(content, 'Part 1: Band Score & Overview', content);
        sections["Part 2: Error Analysis & Corrections"] = _extractSection(content, 'Part 2: Error Analysis & Corrections', content);
        sections["Part 3: Rewritten Essay (User Ideas)"] = _extractSection(content, 'Part 3: Rewritten Essay', content);
        sections["Part 4: Sample Band 8 Essay"] = _extractSection(content, 'Part 4: Sample Band 8 Essay', content);

        setState(() => isLoading = false);
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  double _extractOverallScore(String content) {
    final match = RegExp(r'\*\*Overall Writing Band Score\*\*:\s*([0-9.]+)').firstMatch(content);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  String _extractIntro(String content) {
    final end = content.indexOf('### Part 1');
    if (end == -1) return '';
    return content.substring(0, end).trim();
  }

  String _extractSection(String content, String sectionLabel, String fullContent) {
    final startPattern = '### $sectionLabel';
    final start = fullContent.indexOf(startPattern);
    if (start == -1) return "";

    final nextPartMatch = RegExp(r'### Part \d+:').allMatches(fullContent)
        .skipWhile((m) => m.start <= start)
        .map((m) => m.start)
        .firstOrNull;

    return nextPartMatch != null
        ? fullContent.substring(start, nextPartMatch).trim()
        : fullContent.substring(start).trim();
  }

  void _copyFeedback() {
    final fullText = sections.values.join('\n\n');
    Clipboard.setData(ClipboardData(text: fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff2A4ECA),
        title: const Text('IELTS Feedback', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          if (!isLoading && errorMessage.isEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: _copyFeedback,
              tooltip: "Copy all feedback",
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hiển thị lại 2 bài viết của user
          _EssayReviewSection(
            submissions: widget.submissions,
            elapsedTime: widget.elapsedTime,
          ),
          const SizedBox(height: 24),
          // Feedback AI, chia section như cũ
          ...List.generate(
            sections.length,
                (index) {
              final title = sections.keys.elementAt(index);
              final content = sections[title] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _FeedbackCard(
                  title: title,
                  content: content,
                  index: index + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final String title;
  final String content;
  final int index;

  const _FeedbackCard({required this.title, required this.content, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xff2A4ECA),
                  child: Text(
                    '$index',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2A4ECA),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownBody(
              data: _stripHeader(content),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(fontSize: 15),
                strong: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                em: const TextStyle(color: Colors.blueAccent),
                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                tableHead: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
String _stripHeader(String markdown) {
  final lines = LineSplitter.split(markdown).toList();
  if (lines.isNotEmpty && lines.first.startsWith('### Part')) {
    return lines.sublist(1).join('\n').trim();
  }
  return markdown;
}
class _EssayReviewSection extends StatelessWidget {
  final List<Map<String, String>> submissions;
  final int elapsedTime;

  const _EssayReviewSection({required this.submissions, required this.elapsedTime});

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📝 Your Submitted Essays",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xff2A4ECA),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "⏰ Time spent: ${_formatTime(elapsedTime)}",
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < submissions.length; i++) ...[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.grey[50],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task ${i + 1}:",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2A4ECA)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    submissions[i]['task_description'] ?? '',
                    style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                  const Divider(height: 20, thickness: 1.2),
                  Text(
                    submissions[i]['user_answer'] ?? '',
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
            ),
          )
        ]
      ],
    );
  }
}
