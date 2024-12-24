import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeLoad extends StatefulWidget {
  const HomeLoad({super.key});

  @override
  State<StatefulWidget> createState() => _HomeLoad();
}

class _HomeLoad extends State<HomeLoad> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        width: 393,
        height: 852,
        child: Stack(
          children: [
            Positioned(
              left: 19,
              width: 348,
              top: 711,
              height: 76,
              child: Container(
                width: 348,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0x0056c9ed),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Positioned(
              left: 63,
              width: 29,
              top: 736,
              height: 22,
              child: SvgPicture.asset('lib/icons/ic-home.svg', width: 29, height: 22,),
            ),
            Positioned(
              left: 222,
              width: 23,
              top: 735,
              height: 24,
              child: SvgPicture.asset('lib/icons/ic-journey.svg', width: 23, height: 24,),
            ),
            Positioned(
              left: 296,
              width: 18,
              top: 736,
              height: 22,
              child: SvgPicture.asset('lib/icons/ic-profile.svg', width: 18, height: 22,),
            ),
            const Positioned(
              left: 67,
              width: 22,
              top: 762,
              height: 7,
              child: Text(
                'Home',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 6, color: Color(0xaf4681da), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 147,
              width: 34,
              top: 762,
              height: 7,
              child: Text(
                'Flashcard',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 6, color: Color(0xff000000), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 222,
              width: 27,
              top: 762,
              height: 7,
              child: Text(
                'journey',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 6, color: Color(0xff000000), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 295,
              width: 24,
              top: 762,
              height: 7,
              child: Text(
                'Profile',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 6, color: Color(0xff000000), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 25,
              width: 311,
              top: 392,
              height: 22,
              child: Text(
                'Today’s recommendations',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 20, color: Color(0xffffffff), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 18,
              width: 348.65,
              top: 427,
              height: 76.632,
              child: Container(
                width: 348.65,
                height: 76.632,
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  border: Border.all(color: const Color(0xffe33629), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const Positioned(
              left: 93.559,
              width: 77.638,
              top: 444.516,
              height: 17.516,
              child: Text(
                'Flashcard',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 14, color: Color(0xff000000), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 93.559,
              width: 48.494,
              top: 471.884,
              height: 13.137,
              child: Text(
                'Lesson 8',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 10, color: Color(0xffc9c9c9), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 27.715,
              width: 55.05,
              top: 437.947,
              height: 55.832,
              child: Container(
                width: 55.05,
                height: 55.832,
                decoration: BoxDecoration(
                  color: const Color(0xff28273e),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Positioned(
              left: 29.874,
              width: 50.732,
              top: 445.611,
              height: 44.884,
              child: Image.asset('lib/icons/ic-flashcard.png', width: 50.732, height: 44.884, fit: BoxFit.fill,),
            ),
            Positioned(
              left: 16,
              width: 352,
              top: 220,
              height: 152,
              child: Container(
                width: 352,
                height: 152,
                decoration: BoxDecoration(
                  color: const Color(0x5455acee),
                  border: Border.all(color: const Color(0xff000000), width: 1),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            const Positioned(
              left: 41,
              width: 150,
              top: 249,
              height: 62,
              child: Text(
                'Great, you\'ve logged in 7 days in a row!',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: Color(0xff587dbd), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 32,
              width: 340,
              top: 123,
              height: 113,
              child: Text(
                'Are you ready for our IELTS journey?',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 32, color: Color(0xff0067ac), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 41,
              width: 84,
              top: 324,
              height: 14,
              child: Text(
                '37/10/2024 ',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: Color(0xff7674a4), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 308.682,
              width: 49,
              top: 468.367,
              height: 14,
              child: Text(
                '80/100',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: Color(0xffe33629), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 245.518,
              width: 93.909,
              top: 249.61,
              height: 93.901,
              child: SvgPicture.asset('lib/icons/ic-graph.svg', width: 93.909, height: 93.901,),
            ),
            Positioned(
              left: 18,
              width: 348.65,
              top: 518.742,
              height: 75.553,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    width: 348.65,
                    top: 0,
                    height: 75.553,
                    child: Container(
                      width: 348.65,
                      height: 75.553,
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        border: Border.all(color: const Color(0xffc9c9c9), width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 75.559,
                    width: 90.591,
                    top: 10.793,
                    height: 29.142,
                    child: Text(
                      'The path of the planet',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: Color(0xff000000), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Positioned(
                    left: 75.559,
                    width: 51.732,
                    top: 47.49,
                    height: 12.952,
                    child: Text(
                      'Reading 5',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 9, color: Color(0xffc9c9c9), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 9.715,
                    width: 55.05,
                    top: 10.793,
                    height: 55.046,
                    child: Container(
                      width: 55.05,
                      height: 55.046,
                      decoration: BoxDecoration(
                        color: const Color(0xff28273e),
                        border: Border.all(color: const Color(0xffc9c9c9), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 11.874,
                    width: 50.732,
                    top: 18.349,
                    height: 44.252,
                    child: Image.asset('lib/icons/ic-reading.png', width: 50.732, height: 44.252, fit: BoxFit.fill,),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 18,
              width: 348.65,
              top: 609.406,
              height: 75.553,
              child: Container(
                width: 348.65,
                height: 75.553,
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  border: Border.all(color: const Color(0xffc9c9c9), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const Positioned(
              left: 92.682,
              width: 91,
              top: 637.367,
              height: 29,
              child: Text(
                'Random topic',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: Color(0xff000000), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 93.559,
              width: 48.494,
              top: 659.055,
              height: 12.952,
              child: Text(
                'writing',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 9, color: Color(0xffc9c9c9), fontFamily: 'Montserrat-SemiBold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 27.715,
              width: 55.05,
              top: 620.199,
              height: 55.046,
              child: Container(
                width: 55.05,
                height: 55.046,
                decoration: BoxDecoration(
                  color: const Color(0xff28273e),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Positioned(
              left: 42.826,
              width: 23.747,
              top: 633.151,
              height: 28.062,
              child: SvgPicture.asset('lib/icons/ic-lock.svg', width: 23.747, height: 28.062,),
            ),
            Positioned(
              left: 323,
              width: 48,
              top: 26,
              height: 49,
              child: SvgPicture.asset('lib/icons/ic-circle.svg', width: 48, height: 49,),
            ),
            Positioned(
              left: 337,
              width: 18,
              top: 41,
              height: 19,
              child: SvgPicture.asset('lib/icons/ic-bell.svg', width: 18, height: 19,),
            ),
            Positioned(
              left: 18,
              width: 54,
              top: 26,
              height: 49,
              child: Image.asset('lib/images/starter-img.png', width: 54, height: 49, fit: BoxFit.cover,),
            ),
            const Positioned(
              left: 268,
              width: 41,
              top: 275,
              height: 21,
              child: Text(
                '🚀',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 17.227235133392487, color: Color(0xffffffff), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 308.682,
              width: 49,
              top: 558.367,
              height: 14,
              child: Text(
                'waiting',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: Color(0xffc0c0c0), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Positioned(
              left: 308.682,
              width: 49,
              top: 654.367,
              height: 14,
              child: Text(
                'waiting',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: Color(0xffc0c0c0), fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 146,
              width: 25,
              top: 734,
              height: 25,
              child: Image.asset('lib/icons/ic-homecard.png', width: 50.732, height: 44.884, fit: BoxFit.fill,),
            ),
          ],
        ),
      ),
    );
  }


}
