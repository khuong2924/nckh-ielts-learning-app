import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});

  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  int _currentIndex = 0;
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
                    _buildRoundedContainer('Thanh Huong', 'Animal','100','70'),
                    _buildRoundedContainer('Thanh Huong', 'Animal','100','50'),
                    _buildRoundedContainer('Thanh Huong', 'Animal','100','20'),
                    _buildRoundedContainer('Thanh Huong', 'Animal','100','90'),
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
            'FlashCard',
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
  Widget _buildRoundedContainer(String author, String nameTopic, String numberWords, String progress) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'By',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202244),
                ),
              ),
              SizedBox(width: 5), // Khoảng cách giữa các chữ
              Text(
                author,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nameTopic,
            style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 29,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFF4681DA).withOpacity(0.69),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Words: $numberWords',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 50),
              Row(
                children: [
                  Container(
                    width: 29,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFF4681DA).withOpacity(0.69),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 17,
                        height: 17, 
                        child: CircularProgressIndicator(
                          value: double.parse(progress) / double.parse(numberWords),
                          strokeWidth: 3,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  Text(
                    '$progress/$numberWords',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
