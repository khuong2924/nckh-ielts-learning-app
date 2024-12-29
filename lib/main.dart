import 'package:auth/presentation/pages/account-management/profile-page.dart';
import 'package:auth/presentation/pages/main-page/home-page.dart';
import 'package:auth/presentation/pages/main-page/setting-page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated file from Firebase CLI
import 'presentation/pages/account-management/signin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      home: ProfilePage(), // Start with SigninPage
    );
  }
}
