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
  bool _checkOption1 = false;
  bool _checkOption2 = false;
  bool _checkOption3 = false;
  bool _checkOption4 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildPart('1-13', '1'),
                    _quesPas1(),
                    const SizedBox(height: 20),
                    _buildPart('14-26', '2'),
                    _quesPas2(),
                    _buildSubmitButton(),
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
  Widget _quesPas1() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildPartQ('Write your answers in boxes 1-6 on your answer sheet'),
          const SizedBox(height: 10),
          _buildQ('- The 1____ of London increased rapidly between 1800 and 1850.'),
          const SizedBox(height: 5),
          _buildQ('- The streets were full of horse-drawn vehicles.'),
          const SizedBox(height: 5),
          _buildQ('- The 2____ of London increased rapidly between 1800 and 1850.'),
          const SizedBox(height: 5),
          _buildQ('- The streets were full of horse-drawn vehicles.'),
          const SizedBox(height: 5),
          _buildQ('- The 3____ of London increased rapidly between 1800 and 1850.'),
          const SizedBox(height: 5),
          _buildQ('- The streets were full of horse-drawn vehicles.'),
          const SizedBox(height: 10),
          _buildRow2('Answer 1', 'Answer 2'),
          const SizedBox(height: 10),
          _buildRow2('Answer 3', 'Answer 4'),
          const SizedBox(height: 10),
          _buildRow2('Answer 5', 'Answer 6'),
          const SizedBox(height: 10),
          _buildPartQ('In boxes 7-13 on your answer sheet, write True, False, NG.'),
          const SizedBox(height: 10),
          _buildQ('7. Other countries had built underground railways before the Metropolitan line openened.'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 7'),
          ),
          const SizedBox(height: 10),
          _buildQ('8. Other countries had built underground railways before the Metropolitan line openened.'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 8'),
          ),
          const SizedBox(height: 10),
          _buildQ('9. Other countries had built underground railways before the Metropolitan line openened.'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 9'),
          ),
        ],
      ),
    );
  }
  Widget _quesPas2() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          _buildPartQ('Which section contains the following information? Write the correct letter, A-G, in boxes 14-17 on your answer.'),
          const SizedBox(height: 10),
          _buildQ('NB You may use any letter more than once.'),
          const SizedBox(height: 10),
          _buildQ('14. a mention of negative attitudes'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 14'),
          ),
          const SizedBox(height: 10),
          _buildQ('15. figures demonstrating the environmental'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 15'),
          ),
          const SizedBox(height: 10),
          _buildQ('16. figures demonstrating the environmental'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 16'),
          ),
          const SizedBox(height: 10),
          _buildQ('17. reference to the disadvantages'),
          const SizedBox(height: 10),
          Container(
            width: 150,
            child: _buildRow('Answer 16'),
          ),
          const SizedBox(height: 15),
          _buildPartQ('Choose ONE WORD ONLY from passage Write your answer in boxes 18-21 on your answer.'),
          const SizedBox(height: 10),
          _buildQ('The Roman stadiums of Europe have proved very versatile. The 18_____ of Arles, for example, was converted first into a 19_____, then into a residential.'),
          _buildRow2('Answer 18', 'Answer 19'),
          const SizedBox(height: 10),
          _buildRow2('Answer 20', 'Answer 21'),
          const SizedBox(height: 10),
          _buildPartQ('Choose TWO letters, A-E Write the correct letters in boxes 23 and 24 on your answer. When comparing twentieth-century stadiums to ancient..., which TWO negative?'),
          _buildAnswerCheckbox(_checkOption1, 'They are less versatile', (value) {
            _checkOption1 = value;
          }),
          _buildAnswerCheckbox(_checkOption2, 'They are less imaginatively designed', (value) {
            _checkOption2 = value;
          }),
          _buildAnswerCheckbox(_checkOption3, 'They are less versatile', (value) {
            _checkOption3 = value;
          }),
          _buildAnswerCheckbox(_checkOption4, 'They are less imaginatively designed', (value) {
            _checkOption4 = value;
          }),
        ],
      ),
    );
  }
  Widget _buildPart(String numberQuestion, String numberPassage) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Questions $numberQuestion. Click ',
              style: const TextStyle(
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
                  _showDialog(context, numberPassage, 'Hello'); // Gọi hàm hiển thị dialog khi nhấn vào "here"
                },
            ),
            TextSpan(
              text: ' to read passage $numberPassage',
              style: const TextStyle(
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
    );
  }
  void _showDialog(BuildContext context, String numberPassage, String passage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Passage $numberPassage'),
          content: Text(
            passage
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          _showSubmitDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0067AC),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Test'),
        content: Text('Are you sure you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle final submission
              Navigator.pop(context);
              // Navigate to results page
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
  Widget _buildPartQ(String question) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        question,
        style: const TextStyle(
          color: Color(0xFF404040),
          fontSize: 15,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
  Widget _buildQ(String question) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        question,
        style: const TextStyle(
          color: Color(0xFF404040),
          fontSize: 15,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  Widget _buildRow(String label) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          labelStyle: const TextStyle(
            color: Color(0xFF0067AC),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
          ),
        ),
      ),
    );
  }
  Widget _buildRow2(String label1, String label2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: _buildRow(label1), // Gọi hàm _buildRow đúng cách
        ),
        Expanded(
          child: _buildRow(label2), // Gọi hàm _buildRow đúng cách
        ),
      ],
    );
  }
  Widget _buildAnswerCheckbox(bool checkOption, String answer, Function(bool) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: checkOption,
          onChanged: (bool? value) {
            setState(() {
              onChanged(value!);
            });
          },
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Color(0xFF0067AC);
            }
          }),
        ),
        Text(answer),
      ],
    );
  }
}
