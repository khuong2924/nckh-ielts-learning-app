import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/FlashCard.dart';
import 'flashcard-item.dart';


class FlashcardMain extends StatelessWidget {

  final List<FlashCard> flashcards = [
    FlashCard(
      id: '1',
      title: 'Animal',
      author: 'Khuong',
      totalWords: 50,
      currentProgress: 50,
      maxProgress: 100,
    ),
    FlashCard(
      id: '2',
      title: 'Food',
      author: 'Khuong',
      totalWords: 50,
      currentProgress: 50,
      maxProgress: 100,
    ),


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFC5E8FF)],
          ),
        ),
        child: Column(
          children: [
            CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flashcard',
                        style: TextStyle(
                          color: Color(0xFF202244),
                          fontSize: 21,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildFlashcardList(),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavBar(currentIndex: 1, onTap: (int ) {  },),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -50), // Adjust the second parameter to move the button up
        child: _buildAddButton(),
      ),
    );
  }

  Widget _buildFlashcardList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: flashcards.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: FlashCardItem(flashcard: flashcards[index]),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 60,
      height: 58,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFF0067AC)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Icon(Icons.add, color: Color(0xFF0067AC)),
    );
  }
}