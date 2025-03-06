import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int _currentIndex = 0;
  bool _showEmojiPicker = false;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {'text': 'So excited!', 'isMe': false},
    {'text': 'What should we make?', 'isMe': false},
    {'text': 'Pasta?', 'isMe': false},
    {'text': 'Pasta?', 'isMe': false},
    {'text': 'So excited!', 'isMe': false},
    {
      'image': 'lib/images/shiba.jpg',
      'text': 'or we could make this?',
      'isMe': true
    },
    {'text': 'Sounds good!', 'isMe': false},
    {'text': 'Great!', 'isMe': true},
  ];

  Widget _buildMessage(Map<String, dynamic> message) {
    return Align(
      alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            message['isMe'] ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message['isMe'])
            CircleAvatar(
              backgroundImage: AssetImage('lib/images/shiba.jpg'),
              radius: 16,
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: message['isMe']
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message['image'] != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(message['image'], width: 150),
                  ),
                ),
              if (message['text'] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        message['isMe'] ? Colors.blueAccent : Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: message['isMe'] ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              if (message['file'] != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file,
                          color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(message['fileName'],
                          style: const TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        messages.add({'image': image.path, 'isMe': true});
      });
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        messages.add({
          'file': result.files.single.path,
          'fileName': result.files.single.name,
          'isMe': true
        });
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onNotificationTap: () {}),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(messages[index]),
                ),
              ),
            ),
            Column(
              children: [
                if (_showEmojiPicker)
                  SizedBox(
                    height: 250, // Chiều cao danh sách emoji
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
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.black54),
                        onPressed: _showAttachmentOptions,
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: Colors.black54),
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
                            hintText: 'Type a message...',
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
                        icon: const Icon(Icons.mic, color: Colors.black54),
                        onPressed: () {},
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
