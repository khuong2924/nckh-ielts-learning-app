import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../components/SettingCardSection.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF), // Thêm màu nền gradient
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {
                // Xử lý notification
              },
            ),
            Expanded(
              child: SingleChildScrollView( // Wrap trong SingleChildScrollView để tránh overflow
                child: Column(
                  children: [
                    _starterImg(),
                    const SizedBox(height: 5),
                    _titleSetting(),
                    const SizedBox(height: 15),
                    const SettingsCardSection(),
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
    );
  }


  Widget _starterImg() {
    return Image.asset(
      'lib/images/starter-img-setting.png',  // Đảm bảo đường dẫn đúng
      width: 150,
      height: 150,
      fit: BoxFit.fill,
    );
  }

  Widget _titleSetting() {
    return const Text(
      'CÀI ĐẶT',
      style: TextStyle(
        color: Color(0xFF0067AC),
        fontSize: 20,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
    );
  }





}
