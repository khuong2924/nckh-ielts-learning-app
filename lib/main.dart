 import 'package:auth/presentation/pages/flashcard/flashcard-home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';
 void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await dotenv.load(fileName: ".env");

   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );

   await Supabase.initialize(
     url: 'https://ojjtdegibiythbrqhdkg.supabase.co',
     anonKey: '...',
   );

   await Hive.initFlutter();
   final box = await Hive.openBox('app_box');
   final isLoggedIn = box.get('is_logged_in', defaultValue: false);

   runApp(MyApp(isLoggedIn: isLoggedIn));
 }

 class MyApp extends StatelessWidget {
   final bool isLoggedIn;

   const MyApp({super.key, required this.isLoggedIn});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: 'Flutter App',
       theme: ThemeData(
         primarySwatch: Colors.blue,
       ),
       debugShowCheckedModeBanner: false,
       home: isLoggedIn ? const HomeLoad() : const SigninPage(),
     );
   }
 }
