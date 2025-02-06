// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class FlashCardItem extends StatelessWidget {
//   final FlashCard flashcard;
//
//   const FlashCardItem({
//     Key? key,
//     required this.flashcard,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 126,
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         shadows: [
//           BoxShadow(
//             color: Color(0x3F000000),
//             blurRadius: 4,
//             offset: Offset(0, 4),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildAuthorSection(),
//             SizedBox(height: 10),
//             Text(
//               flashcard.title,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 25,
//                 fontFamily: 'Roboto',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Spacer(),
//             _buildStatsRow(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAuthorSection() {
//     return Row(
//       children: [
//         Text(
//           'By ',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 10,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           flashcard.author,
//           style: TextStyle(
//             color: Color(0xFF787880),
//             fontSize: 10,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatsRow() {
//     return Row(
//       children: [
//         _buildStatItem(
//           icon: Icons.book,
//           text: 'Words:${flashcard.totalWords}',
//         ),
//         SizedBox(width: 30),
//         _buildStatItem(
//           icon: Icons.star,
//           text: '${flashcard.currentProgress}/${flashcard.maxProgress}',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatItem({required IconData icon, required String text}) {
//     return Row(
//       children: [
//         Container(
//           width: 29,
//           height: 28,
//           decoration: ShapeDecoration(
//             color: Color(0xAF4681DA),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: Icon(icon, color: Colors.white, size: 15),
//         ),
//         SizedBox(width: 8),
//         Text(
//           text,
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 14,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }