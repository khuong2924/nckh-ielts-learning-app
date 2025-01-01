import 'package:auth/presentation/pages/main-page/home-page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Đảm bảo import trang ComplaintPage



import 'package:auth/presentation/pages/main-page/setting-page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0056c9ed),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Home', 'lib/icons/ic-home.svg', currentIndex == 0, onTap: () {
            onTap(0);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeLoad()), // Điều hướng đến ComplaintPage
            );
          }),
          _buildNavItem('Flashcard', 'lib/icons/ic-homecard.png', currentIndex == 1, isImage: true, onTap: () => onTap(1)),
          _buildNavItem('Journey', 'lib/icons/ic-journey.svg', currentIndex == 2, onTap: ()=> onTap(2)),
          _buildNavItem('Profile', 'lib/icons/ic-profile.svg', currentIndex == 3, onTap: () {
            onTap(3);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingPage()), // Điều hướng đến ProfilePage
            );
          }),

        ],
      ),
    );
  }

  Widget _buildNavItem(
      String label,
      String iconPath,
      bool isActive,
      {bool isImage = false,
        VoidCallback? onTap}
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isImage
              ? Image.asset(
            iconPath,
            width: 25,
            height: 25,
            fit: BoxFit.fill,
          )
              : SvgPicture.asset(
            iconPath,
            width: 25,
            height: 25,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 6,
              color: isActive ? const Color(0xaf4681da) : Colors.black,
              fontFamily: 'Montserrat-SemiBold',
            ),
          ),
        ],
      ),
    );
  }
}