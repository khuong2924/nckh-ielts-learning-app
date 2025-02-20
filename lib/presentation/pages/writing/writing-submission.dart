import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class IeltsFeedbackPage extends StatefulWidget {
  final String userInput;

  const IeltsFeedbackPage({super.key, required this.userInput});

  @override
  State<IeltsFeedbackPage> createState() => _IeltsFeedbackPageState();
}

class _IeltsFeedbackPageState extends State<IeltsFeedbackPage> {
  bool isLoading = true;
  String score = "N/A";
  String grammarSuggestions = "Không có gợi ý";
  String summary = "Không có tóm tắt";
  String feedback = "Không có phản hồi";

  @override
  void initState() {
    super.initState();
    fetchIeltsFeedback(widget.userInput);
  }

  Future<void> fetchIeltsFeedback(String userInput) async {
    const String apiUrl = "https://api.mistral.ai/v1/chat/completions";
    const String apiKey = "3MVsD1vcXAOTl1qjDx42z2wpLS2KUDvc"; // Thay bằng API Key thật

    final Map<String, dynamic> requestBody = {
      "model": "mistral-medium", // Thử "mistral-medium" nếu cần
      "messages": [
        {"role": "system", "content": "Bạn là giám khảo IELTS. Hãy chấm điểm bài viết."},
        {"role": "user", "content": userInput}
      ],
      "temperature": 0.7
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("📢 API Status Code: ${response.statusCode}");
      print("🔥 API Response: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String aiFeedback = responseData["choices"][0]["message"]["content"];

          setState(() {
            score = "Đang cập nhật..."; // Có thể lấy từ AI nếu cần
            feedback = aiFeedback;
          });
        } catch (e) {
          setState(() {
            feedback = "❌ Lỗi khi parse JSON: $e";
          });
        }
      } else {
        setState(() {
          feedback = "❌ Lỗi API: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (error) {
      setState(() {
        feedback = "⚠️ Lỗi khi gọi API: $error";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả chấm bài")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("📝 Điểm IELTS: $score",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("📌 Gợi ý sửa lỗi:\n$grammarSuggestions",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("📖 Tóm tắt bài viết:\n$summary", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("💡 Phản hồi:\n$feedback",
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
