import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/Vocabulary.dart';

class VocabularyItem extends StatelessWidget {
  final Vocabulary vocabulary;
  final ValueChanged<bool>? onLearningStatusChanged;
  final ValueChanged<bool>? onFavoriteChanged;

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
      height: 55,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                vocabulary.englishWord,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: double.infinity,
            color: Color(0xFF0067AC),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                vocabulary.vietnameseWord,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              vocabulary.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Color(0xFF0067AC),
            ),
            onPressed: () {
              onFavoriteChanged?.call(!vocabulary.isFavorite);
            },
          ),
          IconButton(
            icon: Icon(
              vocabulary.isLearned ? Icons.check_circle : Icons.check_circle_outline,
              color: Color(0xFF0067AC),
            ),
            onPressed: () {
              onLearningStatusChanged?.call(!vocabulary.isLearned);
            },
          ),
        ],
      ),
    );
  }
}