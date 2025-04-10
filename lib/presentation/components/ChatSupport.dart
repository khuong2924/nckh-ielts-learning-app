import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ChatSupportSheet extends StatefulWidget {
  const ChatSupportSheet({super.key});

  @override
  State<ChatSupportSheet> createState() => _ChatSupportSheetState();
}

class _ChatSupportSheetState extends State<ChatSupportSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://yourapp.com',
          'X-Title': 'IELTS Assistant',
        },
        body: jsonEncode({
          "model": "deepseek/deepseek-r1:free",
          "messages": _messages.length > 6
              ? _messages.sublist(_messages.length - 6)
              : _messages,
          "temperature": 0.7,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes)); // ✅ fix tiếng Việt
      final reply = data['choices']?[0]['message']?['content'] ?? 'No reply.';

      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': '⚠️ Error: ${e.toString()}'});
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Text(
                "💬 IELTS Assistant",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xff2A4ECA) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['content'] ?? '',
                          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: 'Ask something...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xff2A4ECA)),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
