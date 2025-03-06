import 'package:auth/presentation/pages/friends-page/connect-friends-page.dart';
import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth/presentation/pages/friends-page/ChatPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  void _loadFriends() async {
    List<Map<String, dynamic>> friends = await _fetchFriends();
    print("Fetched friends: $friends"); // Debug log
    setState(() {
      _friends = friends;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFCFEBFF), Color(0xFFC5E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildFriendsList(),
                    ],
                  ),
                ),
              ),
              BottomNavBar(currentIndex: 3, onTap: (index) {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Friends',
          style: TextStyle(
            color: Color(0xFF202244),
            fontSize: 21,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: Image.asset('lib/icons/ic-add.png', width: 32, height: 32),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConnectFriendPage()));
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xAF4681DA)),
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFF49454F)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Find friend',
                hintStyle: TextStyle(color: Color(0xFF49454F), fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          return _buildFriendItem(_friends[index]);
        },
      ),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(friendId: friend["id"], friendName: friend["name"]),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            _buildAvatarWithBorder(friend["avatar"]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend['name'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Text(friend['last_message'],
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithBorder(String avatarUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: const ShapeDecoration(
        shape: OvalBorder(side: BorderSide(width: 1, color: Color(0xFF0067AC))),
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(avatarUrl, fit: BoxFit.cover)
            : Image.asset("assets/default_avatar.png", fit: BoxFit.cover),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFriends() async {
    String currentUserId = getCurrentUserId();
    if (currentUserId.isEmpty) {
      print("Error: User not logged in");
      return [];
    }

    List<Map<String, dynamic>> friends = [];

    try {
      QuerySnapshot friendSnapshot = await FirebaseFirestore.instance
          .collection('friend_list')
          .where('user_id', isEqualTo: currentUserId)
          .get();

      print("Friend list fetched: ${friendSnapshot.docs.length} documents");

      for (var doc in friendSnapshot.docs) {
        String friendId = doc['friend_id'];

        QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('sender_id', whereIn: [currentUserId, friendId])
            .where('receiver_id', whereIn: [currentUserId, friendId])
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        String lastMessage = "No messages yet";
        DateTime lastInteraction = DateTime(2000);

        if (messageSnapshot.docs.isNotEmpty) {
          lastMessage = messageSnapshot.docs.first['content'];
          lastInteraction =
              (messageSnapshot.docs.first['timestamp'] as Timestamp).toDate();
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (userDoc.exists) {
          friends.add({
            "id": friendId,
            "name": userDoc["name"],
            "avatar": userDoc["avatar"],
            "last_message": lastMessage,
            "last_interaction": lastInteraction
          });
        }
      }

      friends.sort((a, b) => b["last_interaction"].compareTo(a["last_interaction"]));
    } catch (e) {
      print("Error fetching friends: $e");
    }

    return friends;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
