import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatSupportSheet extends StatefulWidget {
  const ChatSupportSheet({super.key});

  @override
  State<ChatSupportSheet> createState() => _ChatSupportSheetState();
}

class _ChatSupportSheetState extends State<ChatSupportSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool isLoading = false;
  final _focusNode = FocusNode();

  // Thay bằng key của bạn!
  final String _apiKey = 'AIzaSyAYd32dmUPmdiNXIH2u5EmbiXzjIB5pM38';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': message});
      isLoading = true;
    });
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 120));
    _scrollToEnd();

    try {
      // Chuẩn hóa messages cho Gemini
      final List<Map<String, dynamic>> parts = [];
      for (var msg in _messages.length > 6 ? _messages.sublist(_messages.length - 6) : _messages) {
        parts.add({
          "role": msg['role'] == "user" ? "user" : "model",
          "parts": [{"text": msg['content'] ?? ''}],
        });
      }
      final uri = Uri.parse(
          "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey"
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"contents": parts}),
      );

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      String reply = "No reply.";
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        reply = data['candidates'][0]['content']?['parts']?[0]?['text'] ?? reply;
      } else if (data['error'] != null) {
        reply = '⚠️ Error: ${data['error']['message'] ?? "Unknown"}';
      }
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 180));
      _scrollToEnd();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': '⚠️ Error: ${e.toString()}'});
        isLoading = false;
      });
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 140,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff191933) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 22,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 14, right: 14, bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xff2A4ECA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.android, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Gemini IELTS Assistant",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xff2A4ECA),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: "Close",
                      )
                    ],
                  ),
                ),
                const Divider(thickness: 1.2, height: 6),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4, right: 4),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: isUser ? 60 : 0,
                            right: isUser ? 0 : 60,
                            top: 6,
                            bottom: 6,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xff2A4ECA)
                                : isDark
                                ? const Color(0xff212146)
                                : const Color(0xfff1f4fc),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isUser ? 18 : 6),
                              bottomRight: Radius.circular(isUser ? 6 : 18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isUser
                                    ? Colors.blue.withOpacity(0.09)
                                    : Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            msg['content'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontSize: 15.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xff2A4ECA).withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xff2A4ECA))),
                              SizedBox(width: 10),
                              Text('Gemini is typing...', style: TextStyle(color: Color(0xff2A4ECA))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onSubmitted: _sendMessage,
                          textInputAction: TextInputAction.send,
                          minLines: 1,
                          maxLines: 6,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: 'Ask IELTS, grammar, writing, tips...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xff24244d) : Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, color: isLoading ? Colors.grey : Color(0xff2A4ECA)),
                        onPressed: isLoading ? null : () => _sendMessage(_controller.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
