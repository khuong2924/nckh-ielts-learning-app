import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onMenuTap, // Thêm sự kiện nhấn vào hình ảnh
            child: Image.asset(
              'lib/images/starter-img.png',
              width: 54,
              height: 49,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                )
              ],
            ),
            child: IconButton(
              icon: SvgPicture.asset('lib/icons/icons8-bell.svg'),
              onPressed: onNotificationTap,
            ),
          ),
        ],
      ),
    );
  }
}
