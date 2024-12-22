import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // Set the desired width
      height: 120, // Set the desired height
      child: Image.asset(
        'lib/images/starter-img.png',
        fit: BoxFit.cover,
      ),
    );
  }
}