import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class FlashCardDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete',
                        style: TextStyle(
                          color: Color(0xFF202244),
                          fontSize: 21,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Progress Circle
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          width: 235,
                          height: 214,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: ShapeDecoration(
                                  color: Color(0xFF0067AC),
                                  shape: OvalBorder(),
                                ),
                              ),
                              Container(
                                width: 216,
                                height: 195,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: OvalBorder(),
                                ),
                                child: Center(
                                  child: Text(
                                    '46%',
                                    style: TextStyle(
                                      color: Color(0xFF0067AC),
                                      fontSize: 40,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Status Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusCard(
                            'Remembered',
                            '12',
                            Color(0xFF4CAF50),
                            Icons.check_circle_outline,
                          ),
                          _buildStatusCard(
                            'Learning',
                            '8',
                            Color(0xFFFFA726),
                            Icons.autorenew,
                          ),
                          _buildStatusCard(
                            'Not Learning',
                            '4',
                            Color(0xFFEF5350),
                            Icons.highlight_off,
                          ),
                        ],
                      ),

                      // Learning Section
                      SizedBox(height: 30),
                      Text(
                        'Learning',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Learning Cards
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLearningCard(
                              title: 'FlashCard',
                              icon: Icons.style,
                              description: 'Học với thẻ ghi nhớ',
                              color: Color(0xFF4CAF50),
                              completedCount: '10',
                            ),
                            _buildLearningCard(
                              title: 'Gõ từ',
                              icon: Icons.keyboard,
                              description: 'Luyện gõ từ vựng',
                              color: Color(0xFF2196F3),
                              completedCount: '18',
                            ),
                            _buildLearningCard(
                              title: 'Trắc nghiệm',
                              icon: Icons.quiz,
                              description: 'Kiểm tra kiến thức',
                              color: Color(0xFFF44336),
                              completedCount: '12',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            BottomNavBar(currentIndex: 1, onTap: (int ) {  },),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard({
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    required String completedCount,
  }) {
    return Container(
      width: 114,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 45,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with background
                Container(
                  padding: EdgeInsets.all(8),
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

                SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Spacer(),

                // Completed count
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: color,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$completedCount completed',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
}