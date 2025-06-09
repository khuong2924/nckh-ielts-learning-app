import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:auth/presentation/pages/main-page/home-page.dart';
import 'package:auth/presentation/pages/friends-page/connect-friends-page.dart';
import 'package:auth/presentation/pages/flashcard/flashcard-home.dart';
import 'package:auth/presentation/pages/account-management/signin.dart';
import 'package:auth/presentation/pages/friends-page/Chat.dart';
import 'package:auth/presentation/pages/reading/reading-home.dart';
import 'package:auth/presentation/pages/test-page/listening-page.dart';

import '../../route_persistence.dart';
import '../friends-page/list-friends-page.dart';
import '../main-page/sample-test-home-page.dart';
import '../main-page/setting-page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final box = await Hive.openBox('app_box');
    bool isLoggedIn = box.get('is_logged_in', defaultValue: false);
    String? userId = box.get('user_id');
    print('[SplashScreen] is_logged_in = $isLoggedIn, user_id = $userId');

    if (!isLoggedIn || userId == null || userId.isEmpty) {
      print('[SplashScreen] Not logged in. Redirect to SigninPage');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
      );
      return;
    }

    String? lastRoute = box.get('last_route');
    Map<String, dynamic>? routeParams = box.get('route_params')?.cast<String, dynamic>();
    print('[SplashScreen] lastRoute = $lastRoute');

    // Default fallback
    Widget target = const HomeLoad();

    if (lastRoute != null) {
      switch (lastRoute) {
        case 'home':
          target = const HomeLoad();
          break;
        case 'homepage':
          target = const HomePage();
          break;
        case 'setting':
          target = const SettingPage();
          break;
        case 'connect_friend':
          target = const ConnectFriendPage();
          break;
        case 'friends':
          target = const FriendsPage();
          break;
        case 'flashcard_home':
          target = const FlashcardHome();
          break;
        case 'chat':
          String? friendId = routeParams?['friendId'];
          String? friendName = routeParams?['friendName'];
          print('[SplashScreen] chat: friendId=$friendId, friendName=$friendName');
          if (friendId != null && friendName != null) {
            target = Chat(friendId: friendId, friendName: friendName);
          } else {
            target = const FriendsPage();
          }
          break;
        case 'reading_home':
          String? testIdStr = routeParams?['testId'];
          print('[SplashScreen] reading_home: testId=$testIdStr');
          int? testId = int.tryParse(testIdStr ?? "");
          if (testId != null) {
            target = ReadingHome(testId: testId);
          } else {
            target = const HomeLoad();
          }
          break;
        case 'listening_test':
          String? testIdStr = routeParams?['testId'];
          print('[SplashScreen] listening_test: testId=$testIdStr');
          int? testId = int.tryParse(testIdStr ?? "");
          if (testId != null) {
            target = ListeningTestPage(testId: testId);
          } else {
            target = const HomeLoad();
          }
          break;
        default:
          print('[SplashScreen] Unknown lastRoute, fallback to HomeLoad');
          target = const HomeLoad();
      }
    }

    print('[SplashScreen] Navigating to: ${target.runtimeType}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
