import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';


class ReadingHome extends StatefulWidget {
  const ReadingHome({super.key});

  @override
  State<ReadingHome> createState() => _ReadingHomeState();
}

class _ReadingHomeState extends State<ReadingHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF), // Thêm màu nền gradient
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {
                // Xử lý notification
              },
            ),
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView( // Wrap trong SingleChildScrollView để tránh overflow
                child: Column(
                  children: [
                    _buildPart1(),
                    _quesPas1(),
                    const SizedBox(height: 20),
                    _buildPart2(),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset('lib/icons/ic-back.svg'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Reading',
            style: TextStyle(
              color: Color(0xFF202244),
              fontSize: 21,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPart1() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Questions 1-13. Click ',
                    style: TextStyle(
                      color: Color(0xFF404040),
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: 'here', // Từ "here" có màu đỏ
                    style: const TextStyle(
                      color: Colors.red, // Màu đỏ cho từ "here"
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _showDialog1(context); // Gọi hàm hiển thị dialog khi nhấn vào "here"
                      },
                  ),
                  const TextSpan(
                    text: ' to read passage 1',
                    style: TextStyle(
                      color: Color(0xFF404040),
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  void _showDialog1(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passage 1'),
          content: const Text(
            'Here is a passage where you can read about various topics. It will help you practice reading comprehension skills.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  void _showDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passage 2'),
          content: const Text(
            'Here is a passage where you can read about various topics. It will help you practice reading comprehension skills.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  void _showDialog3(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passage 3'),
          content: const Text(
            'Here is a passage where you can read about various topics. It will help you practice reading comprehension skills.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  Widget _quesPas1() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Write your answers in boxes 1-6 on your answer sheet',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '- The __________ of London increased rapidly between 1800 and 1850.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '- The streets were full of horse-drawn vehicles.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '- The __________ of London increased rapidly between 1800 and 1850.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '- The streets were full of horse-drawn vehicles.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '- The __________ of London increased rapidly between 1800 and 1850.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '- The streets were full of horse-drawn vehicles.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Answer 1',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      labelStyle: TextStyle(
                        color: Color(0xFF0067AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Answer 2',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      labelStyle: TextStyle(
                        color: Color(0xFF0067AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Answer 3',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      labelStyle: TextStyle(
                        color: Color(0xFF0067AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Answer 4',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      labelStyle: TextStyle(
                        color: Color(0xFF0067AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Answer 5',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      labelStyle: TextStyle(
                        color: Color(0xFF0067AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Answer 6',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      labelStyle: TextStyle(
                        color: Color(0xFF0067AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'In boxes 7-13 on your answer sheet, write True, False, NG.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '7. Other countries had built underground railways before the Metropolitan line openened.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: 150, // Đặt chiều rộng cố định cho TextField
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Answer 7',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                labelStyle: TextStyle(
                  color: Color(0xFF0067AC),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '8. Other countries had built underground railways before the Metropolitan line openened.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: 150, // Đặt chiều rộng cố định cho TextField
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Answer 8',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                labelStyle: TextStyle(
                  color: Color(0xFF0067AC),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '9. Other countries had built underground railways before the Metropolitan line openened.',
              style: TextStyle(
                color: Color(0xFF404040),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: 150, // Đặt chiều rộng cố định cho TextField
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Answer 9',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                labelStyle: TextStyle(
                  color: Color(0xFF0067AC),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPart2() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Questions 14-26. Click ',
                    style: TextStyle(
                      color: Color(0xFF404040),
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: 'here', // Từ "here" có màu đỏ
                    style: const TextStyle(
                      color: Colors.red, // Màu đỏ cho từ "here"
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _showDialog2(context); // Gọi hàm hiển thị dialog khi nhấn vào "here"
                      },
                  ),
                  const TextSpan(
                    text: ' to read passage 2',
                    style: TextStyle(
                      color: Color(0xFF404040),
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
