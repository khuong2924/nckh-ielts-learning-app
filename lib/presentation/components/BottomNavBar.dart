import 'package:auth/presentation/pages/main-page/home-page.dart';
import 'package:auth/presentation/pages/main-page/sample-test-home-page.dart';
import 'package:flutter/material.dart';
import 'package:auth/presentation/pages/flashcard/flashcard-home.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final Color activeColor = const Color.fromARGB(255, 43, 150, 192);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(context, 'Home', 'lib/icons/ic-home.svg', 0),
          _buildNavItem(context, 'Flashcard', 'lib/icons/ic-homecard.png', 1, isImage: true),
          _buildNavItem(context, 'Journey', 'lib/icons/ic-journey.svg', 2),
          _buildNavItem(context, 'Profile', 'lib/icons/ic-profile.svg', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    String iconPath,
    int index,
    {bool isImage = false}
  ) {
    // Use the currentIndex passed to the widget to determine active state
    bool isActive = currentIndex == index;
    final Color activeColor = const Color.fromARGB(255, 43, 150, 192);
    final Color inactiveColor = const Color(0xFF9E9E9E);
    
    return InkWell(
      onTap: () {
        // Call onTap before navigation to update the UI state in the parent widget
        onTap(index);
        
        // Then handle navigation
        _navigateToPage(context, index);
      },
      splashColor: activeColor.withAlpha(25),
      highlightColor: activeColor.withAlpha(51),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: isActive 
                ? (Matrix4.identity()..translate(0.0, -2.0)) 
                : Matrix4.identity(),
              child: isImage
                ? Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    color: isActive ? activeColor : inactiveColor,
                  )
                : SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isActive ? activeColor : inactiveColor,
                      BlendMode.srcIn,
                    ),
                  ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 13 : 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                fontFamily: 'Montserrat-SemiBold',
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: isActive ? 4 : 0),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Separate navigation logic from state management
  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (context.findAncestorWidgetOfExactType<HomeLoad>() == null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => const HomeLoad(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
        break;
      case 1:
        if (context.findAncestorWidgetOfExactType<FlashcardHome>() == null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => const FlashcardHome(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
        break;
      case 2:
        if (context.findAncestorWidgetOfExactType<HomePage>() == null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => const HomePage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
        break;
      case 3:
        if (context.findAncestorWidgetOfExactType<SettingPage>() == null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => const SettingPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
        break;
    }
  }
}