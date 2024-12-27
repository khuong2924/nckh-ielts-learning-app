import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class HomeLoad extends StatefulWidget {
  const HomeLoad({super.key});

  @override
  State<StatefulWidget> createState() => _HomeLoad();
}

class _HomeLoad extends State<HomeLoad> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {
                // Xử lý notification
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 20),
                      _buildStreakCard(),
                      const SizedBox(height: 20),
                      _buildRecommendationsSection(),
                    ],
                  ),
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

  Widget _buildWelcomeSection() {
    return const Text(
      'Are you ready for our IELTS journey?',
      style: TextStyle(
        fontSize: 32,
        color: Color(0xff0067ac),
        fontFamily: 'Montserrat-Bold',
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x5455acee),
        border: Border.all(color: const Color(0xff000000)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Great, you\'ve logged in 7 days in a row!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff587dbd),
                    fontFamily: 'Montserrat-Bold',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '37/10/2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff7674a4),
                    fontFamily: 'Montserrat-Bold',
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SvgPicture.asset(
                'lib/icons/ic-graph.svg',
                width: 94,
                height: 94,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Todays recommendations',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Montserrat-Bold',
          ),
        ),
        const SizedBox(height: 15),
        _buildLessonCard(
          title: 'Flashcard',
          subtitle: 'Lesson 8',
          iconPath: 'lib/icons/ic-flashcard.png',
          score: '80/100',
          borderColor: const Color(0xffe33629),
        ),
        const SizedBox(height: 15),
        _buildLessonCard(
          title: 'The path of the planet',
          subtitle: 'Reading 5',
          iconPath: 'lib/icons/ic-reading.png',
          status: 'waiting',
          borderColor: const Color(0xffc9c9c9),
        ),
        const SizedBox(height: 15),
        _buildLessonCard(
          title: 'Random topic',
          subtitle: 'writing',
          iconPath: 'lib/icons/ic-lock.svg',
          status: 'waiting',
          borderColor: const Color(0xffc9c9c9),
          isLocked: true,
        ),
      ],
    );
  }

  Widget _buildLessonCard({
    required String title,
    required String subtitle,
    required String iconPath,
    String? score,
    String? status,
    required Color borderColor,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xff28273e),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: isLocked
                  ? SvgPicture.asset(
                iconPath,
                width: 24,
                height: 28,
              )
                  : Image.asset(
                iconPath,
                width: 50,
                height: 44,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat-SemiBold',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xffc9c9c9),
                    fontFamily: 'Montserrat-SemiBold',
                  ),
                ),
              ],
            ),
          ),
          if (score != null || status != null)
            Text(
              score ?? status!,
              style: TextStyle(
                fontSize: 12,
                color: score != null
                    ? const Color(0xffe33629)
                    : const Color(0xffc0c0c0),
                fontFamily: 'Montserrat-Bold',
              ),
            ),
        ],
      ),
    );
  }
}