import 'package:flutter/cupertino.dart';

class ClipRounded extends StatelessWidget {
  final Widget child;

  const ClipRounded({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: child,
    );
  }
}