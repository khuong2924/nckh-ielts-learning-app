import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auth/presentation/pages/flashcard/flashcard-learning.dart'; // Import trang FlashCard

import 'learning-category.dart';
class LearningCategoryCard extends StatelessWidget {
  final LearningCategory category;
  final VoidCallback onTap; // Thêm tham số onTap

  const LearningCategoryCard({
    Key? key,
    required this.category,
    required this.onTap, // Nhận tham số onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap, // Gọi hàm onTap khi nhấn
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}