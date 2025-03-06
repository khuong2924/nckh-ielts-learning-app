
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String friendId;
  final String friendName;

  const ChatPage({super.key, required this.friendId, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(friendName)),
      body: Center(child: Text("Chat với $friendName")),
    );
  }
}
