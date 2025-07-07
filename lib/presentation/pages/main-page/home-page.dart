import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/BottomNavBar.dart';
import '../../components/ChatSupport.dart';
import '../../components/CustomAppBar.dart';
import '../../model/TestCard.dart';
import '../account-management/signin.dart';
import 'package:auth/presentation/route_persistence.dart';
class HomeLoad extends StatefulWidget {
  const HomeLoad({super.key});

  @override
  State<HomeLoad> createState() => _HomeLoadState();
}

class _HomeLoadState extends State<HomeLoad> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _streakCount = 1;

  @override
  void initState() {
    super.initState();
    saveLastRoute('home');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();

    _loadStreak();           // 👉 THÊM VÀO ĐÂY
    _loadRecommendedTests();
    _loadRecommendedFlashcardTopic() ;
  }

  Future<void> _loadStreak() async {
    final box = await Hive.openBox('app_box');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = box.get('last_login_date');
    final savedStreak = box.get('streak_count', defaultValue: 1);

    if (lastLogin != null) {
      final last = DateTime.parse(lastLogin);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 1) {
        _streakCount = savedStreak + 1;
      } else if (diff == 0) {
        _streakCount = savedStreak;
      } else {
        _streakCount = 1;
      }
    }

    // Cập nhật
    await box.put('last_login_date', today.toIso8601String());
    await box.put('streak_count', _streakCount);

    setState(() {});
  }

  List<Map<String, dynamic>> _recommendedTests = [];

  Future<void> _loadRecommendedTests() async {
    final userId = (await Hive.openBox('app_box')).get('user_id');

    // 1. Lấy tất cả test_id đã làm
    final doneResponse = await Supabase.instance.client
        .from('test_results')
        .select('test_id')
        .eq('user_id', userId);

    final doneTestIds = (doneResponse as List).map((e) => e['test_id']).toSet();

    // 2. Lấy tất cả test chưa làm
    final allTestsResponse = await Supabase.instance.client
        .from('tests')
        .select();
    final allTests = allTestsResponse as List;

    final unfinishedTests = allTests.where((test) => !doneTestIds.contains(test['id'])).toList();

    unfinishedTests.shuffle(); // trộn ngẫu nhiên

    // 3. Lấy 4 bài
    setState(() {
      _recommendedTests = unfinishedTests.take(4).toList().cast<Map<String, dynamic>>();
    });

  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    final box = await Hive.openBox('app_box');
    await box.delete('user_id');
    await box.put('is_logged_in', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninPage()),
    );
  }
  Map<String, dynamic>? _recommendedFlashcard;
  Future<void> _loadRecommendedFlashcardTopic() async {
    final box = await Hive.openBox('app_box');
    final userId = box.get('user_id');

    final response = await Supabase.instance.client
        .from('flashcards')
        .select()
        .or('author.eq.$userId,author.is.null,author.eq.admin');

    final list = response as List;
    list.shuffle();

    if (list.isNotEmpty) {
      setState(() {
        _recommendedFlashcard = list.first;
      });
    }
  }

  Widget _buildRecommendedFlashcardSection() {
    if (_recommendedFlashcard == null) return const SizedBox();

    final topic = _recommendedFlashcard!;
    final learned = topic['learned'] is int ? topic['learned'] as int : 0;
    final total = topic['total_words'] is int ? topic['total_words'] as int : 1;
    final progress = total > 0 ? learned / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flashcard to review',
          style: TextStyle(fontSize: 20, fontFamily: 'Montserrat-Bold'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF3AB19B).withOpacity(0.5), width: 1.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF3AB19B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['topic'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat-Bold',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$learned / $total words learned'),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3AB19B)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
                            _buildRecommendedFlashcardSection(), // 👈 bạn thêm ở đây
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
              elevation: 8,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const ChatSupportSheet(),
                );
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
                Text(
                  'Great, you\'ve logged in $_streakCount days in a row!',
                  style: const TextStyle(
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
            TextButton(
              onPressed: () {}, // Nếu muốn xem tất cả
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (_recommendedTests.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: _recommendedTests.map((test) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildLessonCard(
                  title: test['test_name'] ?? 'Untitled Test',
                  subtitle: test['test_type'] ?? 'General',
                  level: test['level'],
                  description: test['description'],
                  iconPath: 'lib/icons/ic-flashcard.png', // hoặc chọn icon theo test_type
                  borderColor: const Color(0xFF2A4ECA),
                ),
              );
            }).toList(),
          ),

      ],
    );
  }
  Widget _buildLessonCard({
    required String title,
    required String subtitle,
    required String iconPath,
    String? level,
    String? description,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat-Bold',
                    color: Color(0xFF202244),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip(subtitle, borderColor),
                    const SizedBox(width: 6),
                    if (level != null) _buildChip(level, Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                if (description != null)
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontFamily: 'Montserrat-Medium',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat-Medium',
          color: color,
        ),
      ),
    );
  }
}
