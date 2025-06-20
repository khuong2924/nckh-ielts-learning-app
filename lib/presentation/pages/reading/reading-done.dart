import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth/presentation/pages/test-page/viewanswer.dart';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import '../main-page/sample-test-home-page.dart';
class ReadingDone extends StatefulWidget {
  final double score;
  final int timeTaken;
  final Map<int, int> correctAnswersPerPart;
  final Map<int, Map<int, String>> userAnswers;
  final List<Map<String, dynamic>> parts;
  final Map<int, List<Map<String, dynamic>>> partAnswers;

  const ReadingDone({
    Key? key,
    required this.score,
    required this.timeTaken,
    required this.correctAnswersPerPart,
    required this.userAnswers,
    required this.parts,
    required this.partAnswers,
  }) : super(key: key);

  @override
  State<ReadingDone> createState() => _ReadingDoneState();
}

class _ReadingDoneState extends State<ReadingDone> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  
  @override
  void initState() {
    super.initState();
    
 
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Trả về tỷ lệ đúng cho part với partId
  double _calculateProgress(int partId) {
    final correct = widget.correctAnswersPerPart[partId] ?? 0;
    final total   = widget.partAnswers[partId]?.length ?? 0;
    return total > 0 ? correct / total : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  onNotificationTap: () {
                    // Handle notification
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
                        _buildBand(),
                        const SizedBox(height: 20),
                        _buildTimeInfo(),
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.yellow,
                Colors.green,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),
        ],
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
              height: 24,
              color: Colors.black,
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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: const Text(
            'CONGRATS',
            style: TextStyle(
              color: Color(0xFFE33629),
              fontSize: 40,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Color(0x80E33629),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComment() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: const Text(
            'You Just Completed',
            style: TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 16,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBand() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        
        final endAngle = 2 * math.pi * (math.max(0.1, _scoreAnimation.value) / 9);
        
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0,
              endAngle: endAngle, 
              colors: const [
                Color(0xFF4681DA),
                Color(0xFF6A5AE0),
                Color(0xFFE33629),
                Color(0xFFFF9500),
                Color(0xFF4681DA),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 2 * math.pi),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return CustomPaint(
                          painter: CircleProgressPainter(
                            progress: value,
                            color: const Color(0xFF4681DA),
                          ),
                          child: Container(
                            width: 160,
                            height: 160,
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Band',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0067AC),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _scoreAnimation.value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0067AC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeInfo() {
    final hours = widget.timeTaken ~/ 3600;
    final minutes = (widget.timeTaken % 3600) ~/ 60;
    final seconds = widget.timeTaken % 60;
    
    final timeString = '${hours > 0 ? '$hours hr ' : ''}${minutes > 0 ? '$minutes min ' : ''}${seconds > 0 ? '$seconds sec' : ''}';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Color(0xFF0067AC),
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'Time: $timeString',
            style: const TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRoundContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4681DA), Color(0xFF0067AC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4681DA).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Text(
                'Your Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const SizedBox(height: 16),
              // Sinh hàng ngang hoặc wrap tuỳ số phần
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 20,
                runSpacing: 20,
                children: widget.parts.map((part) {
                  final pid = part['id'] as int;
                  final idx = widget.parts.indexOf(part) + 1;
                  final prog = _calculateProgress(pid);
                  return _buildProgress(idx.toString(), prog);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(String numberPart, double progress) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8.0,
                    backgroundColor: const Color(0xFFE33629).withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE33629)),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067AC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0067AC),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0067AC).withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                'Part $numberPart',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedButton(
          'Exit',
          const Color(0xFF4681DA).withOpacity(0.69),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        const SizedBox(width: 20),
        _buildAnimatedButton(
          'View Answer',
          const Color(0xFF0067AC),
          () {
           
            if (widget.parts.isNotEmpty && widget.userAnswers.isNotEmpty && widget.partAnswers.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAnswersPage(
                    parts: widget.parts,
                    userAnswersPerPart: widget.userAnswers,
                    partAnswers: widget.partAnswers,
                  ),
                ),
              );
            } else {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot view answers: Missing data'),
                  backgroundColor: Colors.red,
                ),
              );
              print('Debug data:');
              print('Parts: ${widget.parts}');
              print('User Answers: ${widget.userAnswers}');
              print('Part Answers: ${widget.partAnswers}');
            }
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedButton(String text, Color color, VoidCallback onPressed) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 5,
              shadowColor: color.withOpacity(0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fix the icon color to be explicitly white
                Icon(
                  text == 'Exit' ? Icons.exit_to_app : Icons.visibility,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Explicitly set text color to white
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(center, radius - (i * 3), paint);
    }
    

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}