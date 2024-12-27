import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeLoad extends StatefulWidget {
  const HomeLoad({super.key});

  @override
  State<StatefulWidget> createState() => _HomeLoad();
}

class _HomeLoad extends State<HomeLoad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
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
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'lib/images/starter-img.png',
            width: 54,
            height: 49,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                )
              ],
            ),
            child: IconButton(
              icon: SvgPicture.asset('lib/icons/icons8-bell.svg'),
              onPressed: () {},
            ),
          ),
        ],
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
    'Today recommendations',
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
                  ? SvgPicture.asset(iconPath)
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

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0056c9ed),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Home', 'lib/icons/ic-home.svg', true),
          _buildNavItem('Flashcard', 'lib/icons/ic-homecard.png', false, isImage: true),
          _buildNavItem('Journey', 'lib/icons/ic-journey.svg', false),
          _buildNavItem('Profile', 'lib/icons/ic-profile.svg', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, String iconPath, bool isActive, {bool isImage = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isImage
            ? Image.asset(
          iconPath,
          width: 25,
          height: 25,
          fit: BoxFit.fill,
        )
            : SvgPicture.asset(
          iconPath,
          width: 25,
          height: 25,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 6,
            color: isActive ? const Color(0xaf4681da) : Colors.black,
            fontFamily: 'Montserrat-SemiBold',
          ),
        ),
      ],
    );
  }
}