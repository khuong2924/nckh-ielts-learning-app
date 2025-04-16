import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../account-management/signin.dart';

class HomeLoad extends StatefulWidget {
  const HomeLoad({super.key});

  @override
  State<HomeLoad> createState() => _HomeLoadState();
}

class _HomeLoadState extends State<HomeLoad> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  onMenuTap: _signOut,
                  onNotificationTap: () {},
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(),
                            const SizedBox(height: 24),
                            _buildStreakCard(),
                            const SizedBox(height: 30),
                            _buildRecommendationsSection(),
                            const SizedBox(height: 80), // tránh bị FAB che
                          ],
                        ),
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

          // FloatingActionButton tại đúng vị trí
          Positioned(
            bottom: 120,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xff2A4ECA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () {

              },
              child: const Icon(Icons.chat_bubble_outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 5),
          child: Text(
            'Are you ready for',
            style: TextStyle(
              fontSize: 30,
              color: Color(0xff0067ac),
              fontFamily: 'Montserrat-Bold',
              height: 1.2,
            ),
          ),
        ),
        const Text(
          'our IELTS journey?',
          style: TextStyle(
            fontSize: 30,
            color: Color(0xff0067ac),
            fontFamily: 'Montserrat-Bold',
            height: 1.2,
          ),
        ),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xff2A4ECA),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF55ACEE), Color(0xFF3B76C4)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF55ACEE).withOpacity(0.3),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
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
                    color: Colors.white,
                    fontFamily: 'Montserrat-Bold',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Keep it up! 🔥',
                    style: TextStyle(
                      color: Color(0xFF3B76C4),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'lib/icons/ic-graph.svg',
            width: 84,
            height: 84,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s recommendations',
              style: TextStyle(fontSize: 20, fontFamily: 'Montserrat-Bold'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xff2A4ECA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff2A4ECA),
                  fontFamily: 'Montserrat-Bold',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLessonCard(
          title: 'Flashcard',
          subtitle: 'Lesson 8',
          iconPath: 'lib/icons/ic-flashcard.png',
          score: '80/100',
          borderColor: const Color(0xffe33629),
          progress: 0.8,
        ),
        const SizedBox(height: 16),
        _buildLessonCard(
          title: 'The path of the planet',
          subtitle: 'Reading 5',
          iconPath: 'lib/icons/ic-reading.png',
          status: 'New',
          borderColor: const Color(0xff55ACEE),
        ),
        const SizedBox(height: 16),
        _buildLessonCard(
          title: 'Random topic',
          subtitle: 'Writing',
          iconPath: 'lib/icons/ic-lock.svg',
          status: 'Premium',
          borderColor: const Color(0xFFFFAB40),
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
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xff28273e),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLocked
                      ? SvgPicture.asset(iconPath, width: 28, height: 28, color: Colors.white)
                      : Image.asset(iconPath, width: 40, height: 40, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat-SemiBold')),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: borderColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: borderColor,
                              fontFamily: 'Montserrat-Medium',
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (score != null || status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: score != null
                                  ? const Color(0xffe33629).withOpacity(0.1)
                                  : status == "Premium"
                                  ? const Color(0xFFFFAB40).withOpacity(0.1)
                                  : const Color(0xff55ACEE).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              score ?? status!,
                              style: TextStyle(
                                fontSize: 12,
                                color: score != null
                                    ? const Color(0xffe33629)
                                    : status == "Premium"
                                    ? const Color(0xFFFFAB40)
                                    : const Color(0xff55ACEE),
                                fontFamily: 'Montserrat-Bold',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
