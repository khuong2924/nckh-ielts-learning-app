import 'dart:ui';

class TestTimer {
  final int durationInMinutes;
  final Function(int) onTick;
  final VoidCallback onFinish;

  TestTimer({
    required this.durationInMinutes,
    required this.onTick,
    required this.onFinish,
  });

  void start() {
    // Implementation
  }

  void stop() {
    // Implementation
  }
}