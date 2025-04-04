import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class FlashCardDone extends StatefulWidget {
  const FlashCardDone({Key? key}) : super(key: key);

  @override
  State<FlashCardDone> createState() => _FlashCardDoneState();
}

class _FlashCardDoneState extends State<FlashCardDone> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  // Removed confetti controller
  
  final double progressPercent = 0.46; // 46%
  
  @override
  void initState() {
    super.initState();
    
    // Removed confetti controller initialization
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    // Removed confetti play
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    // Removed confetti controller dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFC5E8FF)],
          ),
        ),
        child: Column(
          children: [
            CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildProgressSection(),
                          _buildStatusCards(),
                          _buildLearningSection(),
                          _buildActionButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: 1, 
              onTap: (int index) {
                // Handle navigation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        children: [
          const Text(
            'Complete',
            style: TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 28,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0067AC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.restart_alt,
                  color: Color(0xFF0067AC),
                  size: 16,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Try again',
                  style: TextStyle(
                    color: Color(0xFF0067AC),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator
            CircularPercentIndicator(
              radius: 120,
              lineWidth: 12.0,
              animation: true,
              animationDuration: 1500,
              percent: progressPercent,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progressPercent * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF0067AC),
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Completed',
                    style: TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: const Color(0xFF0067AC),
              backgroundColor: const Color(0xFF0067AC).withOpacity(0.1),
              rotateLinearGradient: true,
              widgetIndicator: Container(
                width: 24,
                height: 24,
                
                child: const Center(
                  child: Icon(
                    Icons.star,
                    color: Color(0xFFFFC107),
                    size: 16,
                  ),
                ),
              ),
            ),
            
            // Achievement badge
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Great job! +15 XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatusCard(
            'Remembered',
            '12',
            const Color(0xFF4CAF50),
            Icons.check_circle_outline,
          ),
          const SizedBox(width: 12),
          _buildStatusCard(
            'Learning',
            '8',
            const Color(0xFFFFA726),
            Icons.autorenew,
          ),
          const SizedBox(width: 12),
          _buildStatusCard(
            'Not Learning',
            '4',
            const Color(0xFFEF5350),
            Icons.highlight_off,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B6B6B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Text(
                'Learning',
                style: TextStyle(
                  color: Color(0xFF202244),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
             
            ],
          ),
        ),

        // Optimized learning cards display
        Container(
          height: 230, // Fixed height for the container
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildLearningCard(
                title: 'FlashCard',
                icon: Icons.style,
                description: 'Learn with memory cards',
                color: const Color(0xFF4CAF50),
                completedCount: '10',
                recommended: true,
              ),
              const SizedBox(width: 12),
              _buildLearningCard(
                title: 'Type Words',
                icon: Icons.keyboard,
                description: 'Practice typing vocabulary',
                color: const Color(0xFF2196F3),
                completedCount: '18',
              ),
              const SizedBox(width: 12),
              _buildLearningCard(
                title: 'Quiz',
                icon: Icons.quiz,
                description: 'Test your knowledge',
                color: const Color(0xFFF44336),
                completedCount: '12',
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningCard({
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    required String completedCount,
    bool recommended = false,
  }) {
    return Container(
      width: 160, // Slightly wider for better readability
      margin: const EdgeInsets.only(bottom: 10), // Added margin for better spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Recommended badge
          if (recommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF202244),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Completed count with progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: color,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$completedCount completed',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: int.parse(completedCount) / 24, // Example total is 24
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Interactive ripple effect
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Handle tap
              },
              splashColor: color.withOpacity(0.1),
              highlightColor: color.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to next section
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0067AC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF0067AC).withOpacity(0.3),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}