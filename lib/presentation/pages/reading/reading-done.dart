import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth/presentation/pages/reading/reading-home.dart';

class ReadingDone extends StatefulWidget {
  const ReadingDone({super.key});

  @override
  State<ReadingDone> createState() => _ReadingDoneState();
}

class _ReadingDoneState extends State<ReadingDone> {
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
                    _buildCongrats(),
                    const SizedBox(height: 10),
                    _buildComment(),
                    const SizedBox(height: 20),
                    _buildBand('7.5'),
                    const SizedBox(height: 20),
                    _buildRoundContainer(),
                    const SizedBox(height: 20),
                    _buildButtons(),
                    const SizedBox(height: 20),
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
            icon: SvgPicture.asset(
              'lib/icons/ic-close.svg',
              width: 24,
              height: 24, // Đã sửa chính tả từ "heigh" thành "height"
              color: Colors.black, // Đã sửa màu sắc từ "Color.Black" thành "Colors.black"
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Complete',
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
  Widget _buildCongrats() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'CONGRATS',
        style: const TextStyle(
          color: Color(0xFFE33629),
          fontSize: 40,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  Widget _buildComment() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'You Just Completed',
        style: const TextStyle(
          color: Color(0xFFE0067AC),
          fontSize: 14,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  Widget _buildBand(String band) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4681DA).withOpacity(0.4),
            Color(0xFFE33629).withOpacity(0.4),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4681DA).withOpacity(0.4),
            ),
          ),
          const Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: Text(
              'Band',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                band,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildRoundContainer() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF4681DA).withOpacity(0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Color(0xFF4681DA).withOpacity(0.26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '30',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0067AC),
                                ),
                              ),
                              Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0067AC).withOpacity(0.61),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name this test',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Band 7.5 - 53m57s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC).withOpacity(0.61),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgress('1', 0.7),
                      _buildProgress('2', 0.6),
                      _buildProgress('3', 0.8),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProgress(String numberPart, double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6.0,
                backgroundColor: Color(0xFFE33629).withOpacity(0.4),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE33629)),
              ),
            ),
            Text(
              '${(progress * 10).toInt()}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Part $numberPart',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
      ],
    );
  }
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ReadingHome()),
                  (Route<dynamic> route) => false,
            );

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4681DA).withOpacity(0.69),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: Text(
            'Try Again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            print("View Answer");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0067AC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: Text(
            'View Answer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

}

