import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class Chat extends StatefulWidget {
  final String friendId;
  final String friendName;

  const Chat({super.key, required this.friendId, required this.friendName});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
  }

  /// 🔹 Hàm tạo ID cuộc trò chuyện duy nhất (ĐÃ SỬA LỖI)
  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Đảm bảo ID luôn giống nhau giữa hai người
    return ids.join("_");
  }

  /// 🔹 Gửi tin nhắn văn bản
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String myId = _auth.currentUser!.uid;
    String messageText = _controller.text.trim();

    await _firestore
        .collection('messages')
        .doc(_getChatRoomId(myId, widget.friendId))
        .collection('chats')
        .add({
      'text': messageText,
      'senderId': myId,
      'receiverId': widget.friendId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  /// 🔹 Chọn ảnh từ thư viện và gửi
  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      String myId = _auth.currentUser!.uid;

      await _firestore
          .collection('messages')
          .doc(_getChatRoomId(myId, widget.friendId))
          .collection('chats')
          .add({
        'imageBase64': base64Image,
        'senderId': myId,
        'receiverId': widget.friendId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🔹 Chọn file đính kèm
  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      // Lưu file vào Firestore hoặc Firebase Storage (cần triển khai)
    }
  }

  /// 🔹 Hiển thị các tùy chọn đính kèm
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Chọn ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Chọn file'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Xây dựng tin nhắn hiển thị trên màn hình
  Widget _buildMessage(Map<String, dynamic> message) {
    bool isMe = message['isMe'] ?? false;
    String text = message['text'] ?? '';
    String? imageBase64 = message['imageBase64'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundImage: AssetImage('lib/images/shiba.jpg'),
              radius: 16,
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              if (imageBase64 != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Image.memory(
                    base64Decode(imageBase64),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onNotificationTap: () {}),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .doc(_getChatRoomId(_auth.currentUser!.uid, widget.friendId))
                    .collection('chats')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return {
                      'text': data['text'] ?? '',
                      'imageBase64': data['imageBase64'],
                      'senderId': data['senderId'] ?? '',
                      'isMe': data['senderId'] == _auth.currentUser!.uid,
                    };
                  }).toList();

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) => _buildMessage(messages[index]),
                  );
                },
              ),
            ),
            Column(
              children: [
                if (_showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        setState(() {
                          _controller.text += emoji.emoji;
                        });
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.black54),
                        onPressed: _showAttachmentOptions,
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black54),
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
