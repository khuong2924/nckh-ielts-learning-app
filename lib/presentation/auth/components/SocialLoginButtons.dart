import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Or login with',
          style: TextStyle(
            color: Color(0xff3B4054),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: SvgPicture.asset('lib/images/devicon_google.svg'),
              iconSize: 40,
              onPressed: () {
                // Handle Google login
              },
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: SvgPicture.asset('lib/images/logos_facebook.svg'),
              iconSize: 40,
              onPressed: () {
                // Handle Facebook login
              },
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: SvgPicture.asset('lib/images/logos_twitter.svg'),
              iconSize: 40,
              onPressed: () {
                // Handle Twitter login
              },
            ),
          ],
        ),
      ],
    );
  }
}