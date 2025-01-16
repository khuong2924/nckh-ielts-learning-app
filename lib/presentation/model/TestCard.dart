import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import'package:auth/presentation/pages/test-page/listening-page.dart';
class TestCard extends StatelessWidget {
  final String? title;
  final String? description;
  final String? testType; // Thêm thuộc tính testType
  final VoidCallback? onTap;

  const TestCard({
    Key? key,
    this.title,
    this.description,
    this.testType,  // Khai báo testType trong constructor
    this.onTap,
  }) : super(key: key);

  factory TestCard.fromJson(Map<String, dynamic> json) {
    return TestCard(
      title: json['title'],
      description: json['description'],
      testType: json['test_type'], // Kiểm tra lại trường này
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left black container
            Container(
              width: 130,
              height: 150,
              decoration: const ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  'Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 36,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF0067AC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Kiểm tra testType khi nhấn vào "Làm bài"
                          if (testType == 'listening') {

                            // Chuyển hướng tới trang ListeningTestPage
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ListeningTestPage(test: this)));
                          } else {
                            debugPrint("testType is NOT listening, testType: $testType");
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Làm bài',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
