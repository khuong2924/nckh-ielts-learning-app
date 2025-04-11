import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/Vocabulary.dart';

class VocabularyItem extends StatelessWidget {
  final Vocabulary vocabulary;
  final Future<void> Function(bool)? onLearningStatusChanged;
  final Future<void> Function(bool)? onFavoriteChanged;

  const VocabularyItem({
    Key? key,
    required this.vocabulary,
    this.onLearningStatusChanged,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(vocabulary.englishWord,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(width: 1, height: double.infinity, color: Color(0xFF0067AC)),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () => _showVocabularyDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0067AC),      // Màu nền
                  foregroundColor: Colors.white,          // Màu chữ
                ),
                child: Text(
                  "View",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          ),
          IconButton(
            icon: Icon(
              vocabulary.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Color(0xFF0067AC),
            ),
            onPressed: () async {
              if (onFavoriteChanged != null) {
                await onFavoriteChanged!(!vocabulary.isFavorite);
              }
            },
          ),
          IconButton(
            icon: Icon(
              vocabulary.isLearned ? Icons.check_circle : Icons.check_circle_outline,
              color: Color(0xFF0067AC),
            ),
            onPressed: () async {
              if (onLearningStatusChanged != null) {
                await onLearningStatusChanged!(!vocabulary.isLearned);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showVocabularyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF0067AC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF0067AC).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.language, color: Color(0xFF0067AC)),
                      SizedBox(width: 10),
                      Text(
                        'Vocabulary Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          vocabulary.englishWord,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'meaning',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          vocabulary.meaning,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Color(0xFF0067AC),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}