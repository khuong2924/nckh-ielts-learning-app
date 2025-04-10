import 'package:auth/presentation/pages/flashcard/flashcard-home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File được tạo bởi Firebase CLI
import 'presentation/pages/flashcard/flashcard-done-result.dart'; // Corrected import path
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase package
import 'package:auth/presentation/pages/flashcard/vocabulary-main.dart';
import 'package:auth/presentation/pages/reading/reading-home.dart';
import 'package:auth/presentation/pages/account-management/signin.dart';
import 'package:auth/presentation/pages/reading/reading-done.dart';
import 'package:auth/presentation/pages/main-page/home-page.dart';
import 'package:auth/presentation/pages/account-management/signup.dart';
import 'package:auth/presentation/pages/account-management/splash_screen.dart';
import 'package:auth/presentation/pages/statistical/statistical.dart';
import 'package:auth/presentation/pages/friends-page/chat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: 'https://ojjtdegibiythbrqhdkg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9qanRkZWdpYml5dGhicnFoZGtnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzNjA0MTAsImV4cCI6MjA1MTkzNjQxMH0.bkQUcjjlb7tBOokl0yWX01z4tz1A7DDS3DryVu_6HnI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<int, int> sampleCorrectAnswers = {
      1: 3,
      2: 4,
      3: 5,
    };

    final Map<int, Map<int, String>> sampleUserAnswers = {
      1: {1: 'A', 2: 'B', 3: 'C', 4: 'D'},
      2: {1: 'B', 2: 'C', 3: 'A', 4: 'D', 5: 'B'},
      3: {1: 'C', 2: 'D', 3: 'A', 4: 'B', 5: 'C', 6: 'D'},
    };

    final List<Map<String, dynamic>> sampleParts = [
      {'id': 1, 'title': 'Part 1'},
      {'id': 2, 'title': 'Part 2'},
      {'id': 3, 'title': 'Part 3'},
    ];

    final Map<int, List<Map<String, dynamic>>> samplePartAnswers = {
      1: [
        {'questionNumber': 1, 'correctAnswer': 'A'},
        {'questionNumber': 2, 'correctAnswer': 'B'},
        {'questionNumber': 3, 'correctAnswer': 'C'},
        {'questionNumber': 4, 'correctAnswer': 'D'},
      ],
      2: [
        {'questionNumber': 1, 'correctAnswer': 'B'},
        {'questionNumber': 2, 'correctAnswer': 'C'},
        {'questionNumber': 3, 'correctAnswer': 'A'},
        {'questionNumber': 4, 'correctAnswer': 'D'},
        {'questionNumber': 5, 'correctAnswer': 'B'},
      ],
      3: [
        {'questionNumber': 1, 'correctAnswer': 'C'},
        {'questionNumber': 2, 'correctAnswer': 'D'},
        {'questionNumber': 3, 'correctAnswer': 'A'},
        {'questionNumber': 4, 'correctAnswer': 'B'},
        {'questionNumber': 5, 'correctAnswer': 'C'},
        {'questionNumber': 6, 'correctAnswer': 'D'},
      ],
    };

    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // home: ReadingDone(
      //   score: 7.5,
      //   timeTaken: 3600,
      //   correctAnswersPerPart: sampleCorrectAnswers,
      //   userAnswers: sampleUserAnswers,
      //   parts: sampleParts,
      //   partAnswers: samplePartAnswers,
      // ),
      home: FlashcardHome(),
    );
  }
}
