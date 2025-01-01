import 'package:flutter/material.dart';
import 'package:auth/presentation/pages/account-management/profile-page.dart';
import 'package:auth/presentation/pages/account-management/complaint-page.dart';

class SettingsCardSection extends StatelessWidget {
  const SettingsCardSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: 'lib/icons/ic-setting.png',
            title: 'Setting',
            backgroundColor: const Color(0xFFD1EDFF),
            onTap: () {
              // Tạm thời để trống
            },
          ),
          const SizedBox(height: 15),
          _buildSettingItem(
            icon: 'lib/icons/ic-report.png',
            title: 'Report',
            backgroundColor: const Color(0xFFC5E8FF),
            onTap: () {
              // Xử lý khi nhấn vào Report (nếu cần)
            },
          ),
          const SizedBox(height: 15),
          _buildSettingItem(
            icon: 'lib/icons/ic-error.png',
            title: 'Complaint',
            backgroundColor: const Color(0xFFC5E8FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComplaintPage()),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildSettingItem(
            icon: 'lib/images/starter-img-setting.png',
            title: 'Personalization',
            backgroundColor: const Color(0xFFC5E8FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required String title,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 63,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black54,
            size: 24,
          ),
        ],
      ),
    );
  }
}