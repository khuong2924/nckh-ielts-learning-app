import 'dart:convert';
import 'package:auth/presentation/pages/writing/writing-page.dart';
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
  final int testId;
  final String? cachedComment;

  const IeltsFeedbackPage({
    Key? key,
    required this.submissions,
    required this.elapsedTime,
    required this.testId,
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
    "Part 5: Recommendation": "", // ← mới
  };
  List<Map<String, dynamic>> otherTests = [];
  bool isLoading = true;
  String errorMessage = "";
  late int elapsedTime;
  int recommendationId = -1;
  String recommendationName = '';
  String bandScore = '';

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
    sections["Overview & Scores"] =
        _extractIntro(content);
    sections["Part 1: Band Score & Overview"] =
        _extractSection(content, 'Part 1: Band Score & Overview', content);
    sections["Part 2: Error Analysis & Corrections"] =
        _extractSection(
            content, 'Part 2: Error Analysis & Corrections', content);
    sections["Part 3: Rewritten Essay (User Ideas)"] =
        _extractSection(content, 'Part 3: Rewritten Essay', content);
    sections["Part 4: Sample Band 8 Essay"] =
        _extractSection(content, 'Part 4: Sample Band 8 Essay', content);
    sections["Part 5: Recommendation"] =
        _extractSection(
            content, 'Part 5: Recommendation', content); // <-- Bổ sung

    // Lấy recommendationId và Name từ cache content
    final recMap = _parseRecommendation(content);
    recommendationId = recMap['id'] as int? ?? -1;
    recommendationName = recMap['name'] as String? ?? '';

    setState(() => isLoading = false);
  }


  Future<void> fetchFeedback() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      // A) Lấy submissions như trước
      final task1 = widget.submissions.isNotEmpty ? widget.submissions[0] : {};
      final task2 = widget.submissions.length > 1 ? widget.submissions[1] : {};

      final description1 = task1['task_description'] ?? '';
      final content1 = task1['user_answer'] ?? '';
      final description2 = task2['task_description'] ?? '';
      final content2 = task2['user_answer'] ?? '';

      // B) Query Supabase lấy các writing test khác
      final resp = await Supabase.instance.client
          .from('tests')
          .select('id, test_name, keywords') // column `keyword` đã lưu mảng
          .eq('test_type', 'writing')
          .neq('id', widget.testId)
          .order('id');

      if (resp is List) {
        otherTests = resp.cast<Map<String, dynamic>>();
      }

      final otherTestsInfo = otherTests.map((t) {
        final id = t['id'];
        final name = t['test_name'];
        final kws = (t['keywords'] as List? ?? []).join(', ');
        return '- $id: $name: $kws';
      }).join('\n');

      // D) Tạo prompt và gọi AI
      final prompt = _buildPrompt(
        description1: description1,
        content1: content1,
        description2: description2,
        content2: content2,
        otherTestsInfo: otherTestsInfo,
      );

      final aiRes = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "mistral-medium",
          "messages": [
            {"role": "system", "content": "You are a strict IELTS examiner."},
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.7,
        }),
      );
      if (aiRes.statusCode != 200) {
        throw Exception("API Error ${aiRes.statusCode}");
      }
      final aiBody = jsonDecode(aiRes.body);
      final content = aiBody['choices'][0]['message']['content'] as String;

      // E) Lưu test_results (bạn có thể upsert nếu cần)
      final box = await Hive.openBox('app_box');
      final uid = box.get('user_id') as String;
      await Supabase.instance.client
          .from('test_results')
          .upsert({
        'user_id': uid,
        'test_id': widget.testId,
        'score': _extractOverallScore(content),
        'completed_at': DateTime.now().toIso8601String(),
        'total_questions': widget.submissions.length,
        'time': widget.elapsedTime,
        'comment': content,
      },
          onConflict: 'user_id,test_id' // khai báo các trường unique constraint
      );

      // F) Phân tích các section 1–5
      sections["Overview & Scores"] = _extractIntro(content);
      sections["Part 1: Band Score & Overview"] =
          _extractSection(content, 'Part 1: Band Score & Overview', content);
      sections["Part 2: Error Analysis & Corrections"] = _extractSection(
          content, 'Part 2: Error Analysis & Corrections', content);
      sections["Part 3: Rewritten Essay (User Ideas)"] =
          _extractSection(content, 'Part 3: Rewritten Essay', content);
      sections["Part 4: Sample Band 8 Essay"] =
          _extractSection(content, 'Part 4: Sample Band 8 Essay', content);
      final recMap = _parseRecommendation(content);
      final recId = recMap['id'] as int? ?? -1;
      final recName = recMap['name'] as String? ?? '';
// Lưu tạm vào state
      setState(() {
        recommendationId = recId;
        recommendationName = recName;
        isLoading = false;
      });
      sections["Part 5: Recommendation"] =
          _extractSection(content, 'Part 5: Recommendation', content);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Map<String, dynamic> _parseRecommendation(String content) {
    // Tìm đoạn ```json ... ```
    final blockMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(
        content);
    if (blockMatch != null) {
      final jsonStr = blockMatch.group(1)!.trim();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }
    // Nếu không có block code thì fallback về cũ:
    final jsonMatch = RegExp(r'\{[\s\S]*\}$').firstMatch(content);
    if (jsonMatch != null) {
      final jsonStr = jsonMatch.group(0)!;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }
    return {};
  }

  String _buildPrompt({
    required String description1,
    required String content1,
    required String description2,
    required String content2,
    required String otherTestsInfo,
  }) {
    return '''
You are an IELTS Writing examiner. Please analyze the two essays below.

Format your answer in **Markdown** and divide your response into 4 clear sections with the following titles using \`###\` headings:

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

---

**Other writing tests and their keywords:**  
$otherTestsInfo

### Part 5: Recommendation

Based on the user's overall performance and the list above, recommend one test they should take next.  
**At the very end of your answer, after all explanations, output ONLY a JSON code block with exactly two fields (id, name) on a new line, and nothing after the code block. Example:**

\`\`\`json
{"id": 13, "name": "IELTS Writing Practice Test H"}
\`\`\`

''';
  }

  double _extractOverallScore(String content) {
    final match = RegExp(r'\*\*Overall Writing Band Score\*\*:\s*([0-9.]+)')
        .firstMatch(content);
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

  String _extractSection(String fullContent, String sectionLabel,
      String content) {
    final startPattern = '### $sectionLabel';
    final start = fullContent.indexOf(startPattern);
    if (start == -1) return "";

    final nextMatch = RegExp(r'### Part \d+:')
        .allMatches(fullContent)
        .skipWhile((m) => m.start <= start)
        .map((m) => m.start)
        .firstWhere((_) => true, orElse: () => fullContent.length);

    return fullContent.substring(start, nextMatch).trim();
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
    // Tính bandScore trước khi build UI
    String bandScore = '';
    final bandScoreMatch = RegExp(
        r'\*\*Overall Writing Band Score\*\*:\s*([0-9.]+)')
        .firstMatch(sections["Overview & Scores"] ?? '');
    if (bandScoreMatch != null) bandScore = bandScoreMatch.group(1) ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff2A4ECA),
        title: const Text(
          'IELTS Feedback',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (!isLoading && errorMessage.isEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: _copyFeedback,
              tooltip: "Copy all feedback",
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1) Hiển thị lại hai bài essay của user
          _EssayReviewSection(
            submissions: widget.submissions,
            elapsedTime: widget.elapsedTime,
          ),
          const SizedBox(height: 24),

          if (bandScore.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                decoration: BoxDecoration(
                  color: Color(0xff2A4ECA),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.20),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Colors.amberAccent, size: 36),
                        const SizedBox(width: 12),
                        Text(
                          bandScore,
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 5, color: Colors.black26)],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "OVERALL BAND SCORE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 3) Các Feedback Card
          for (var i = 0; i < sections.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _FeedbackCard(
                title: sections.keys.elementAt(i),
                content: sections.values.elementAt(i),
                index: i + 1,
                otherTests: otherTests,
                onNavigate: (testId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WritingPage(testId: testId)),
                  );
                },
                recommendationId: recommendationId,
                recommendationName: recommendationName,
              ),
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
  final List<Map<String, dynamic>> otherTests;
  final void Function(int) onNavigate;
  final int recommendationId;
  final String recommendationName;

  const _FeedbackCard({
    required this.title,
    required this.content,
    required this.index,
    required this.otherTests,
    required this.onNavigate,
    required this.recommendationId,
    required this.recommendationName,
  });

  @override
  Widget build(BuildContext context) {
    if (title == 'Part 5: Recommendation') {
      // Tách phần mô tả markdown trước block code (nếu có)
      final desc = content.split('```json').first.trim();

      // Loại luôn dòng đầu "### Part 5: Recommendation" nếu có
      final descWithoutHeading = desc.replaceFirst(RegExp(r'^#+\s*Part 5: Recommendation\s*'), '').trim();

      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Không còn Text('$index. $title') nữa!
              if (descWithoutHeading.isNotEmpty)
                Text(descWithoutHeading),
              const SizedBox(height: 20),
              if (recommendationId != -1)
                Center(
                  child: ElevatedButton(
                    onPressed: () => onNavigate(recommendationId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(recommendationName),
                  ),
                )
              else
                const Text('No recommendation available.'),
            ],
          ),
        ),
      );
    }
    String cleanContent = content;
    final titleReg = RegExp('^${RegExp.escape(title)}\\s*\\n?', caseSensitive: false);
    cleanContent = cleanContent.replaceFirst(titleReg, '');

    // Các phần khác vẽ Markdown như cũ
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != 'Part 5: Recommendation') ...[
              Text(
                title,
                style: TextStyle(
                  color: Color(0xff2A4ECA),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
            ],
            MarkdownBody(data: content),
          ],
        ),
      ),
    );
  }
}

class _EssayReviewSection extends StatelessWidget {
  final List<Map<String, String>> submissions;
  final int elapsedTime;

  const _EssayReviewSection({
    required this.submissions,
    required this.elapsedTime,
  });

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      for (var i = 0; i < submissions.length; i++)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.grey[50],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Task ${i + 1}:",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2A4ECA),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                submissions[i]['task_description'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
              const Divider(height: 20, thickness: 1.2),
              Text(
                submissions[i]['user_answer'] ?? '',
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ]),
          ),
        ),
    ]);
  }
}
