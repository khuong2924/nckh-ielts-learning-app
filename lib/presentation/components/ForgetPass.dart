
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../pages/account-management/reset-password.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<StatefulWidget> createState() => Forget();
}

class Forget extends State<ForgetPass> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Forget your password? ',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 13,
                color: Color(0xff747577),
                fontFamily: 'Montserrat-SemiBold',
                fontWeight: FontWeight.normal,
              ),
            ),
            TextSpan(
              text: 'Reset now.',
              style: const TextStyle(
                decoration: TextDecoration.none,
                fontSize: 13,
                color: Colors.blue, // Change the color here
                fontFamily: 'Montserrat-SemiBold',
                fontWeight: FontWeight.normal,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>ResetPassword()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}