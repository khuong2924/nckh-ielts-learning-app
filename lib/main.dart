import 'package:auth/presentation/pages/flashcard/flashcard-home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File được tạo bởi Firebase CLI
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
      home: SigninPage(),
    );
  }
}
