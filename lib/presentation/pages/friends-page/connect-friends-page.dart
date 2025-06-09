import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

import '../../route_persistence.dart';

class ConnectFriendPage extends StatefulWidget {
  const ConnectFriendPage({super.key});

  @override
  State<ConnectFriendPage> createState() => _ConnectFriendPageState();
}

class _ConnectFriendPageState extends State<ConnectFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _friendRequests = [];
  bool _isSearching = false;
  Widget _buildFriendRequests() {
    return _friendRequests.isEmpty
        ? const Center(child: Text('No friend requests'))
        : ListView.builder(
      itemCount: _friendRequests.length,
      itemBuilder: (_, index) {
        final request = _friendRequests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: request['avatar'].isNotEmpty
                  ? NetworkImage(request['avatar'])
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
              radius: 25,
            ),
            title: Text(request['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: ElevatedButton(
              onPressed: () => _acceptFriendRequest(request['id'], request['sender_id']),
              child: const Text("Accept"),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    saveLastRoute('connect_friend'); // <--- Thêm dòng này!
    _fetchFriendRequests();
  }

  Future<String?> getCurrentUserId() async {
    final box = await Hive.openBox('app_box');
    return box.get('user_id');
  }

  Future<void> _fetchFriendRequests() async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiver_id', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      List<Map<String, dynamic>> friendRequests = [];

      for (var doc in querySnapshot.docs) {
        String senderId = doc['sender_id'];

        DocumentSnapshot senderSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(senderId).get();

        if (senderSnapshot.exists) {
          final senderData = senderSnapshot.data() as Map<String, dynamic>;
          friendRequests.add({
            'id': doc.id,
            'sender_id': senderId,
            'username': senderData['username'] ?? 'Unknown',
            'avatar': senderData['avatar'] ?? '',
          });
        }
      }

      setState(() {
        _friendRequests = friendRequests;
      });
    } catch (e) {
      print("Error fetching friend requests: $e");
    }
  }

  Future<void> _fetchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _users = [];
      });
      return;
    }

    String myId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot myDoc = await FirebaseFirestore.instance.collection('users').doc(myId).get();
    List<dynamic> myFriends = myDoc['friend_list'] ?? [];

    try {
      QuerySnapshot querySnapshot;

      if (query.contains("@")) {
        // Nếu nhập email → tìm theo email
        querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: query)
            .get();
      } else {
        // Nếu không có '@' → tìm theo username
        querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: query)
            .get();
      }

      List<Map<String, dynamic>> users = querySnapshot.docs
          .where((doc) => doc.id != myId && !myFriends.contains(doc.id)) // ⚠️ Lọc bỏ bản thân & bạn bè
          .map((doc) {
        return {
          'id': doc.id,
          'username': doc['username'] ?? 'Unknown',
          'email': doc['email'] ?? 'No email',
          'avatar': doc['avatar'] ?? '',
        };
      }).toList();

      setState(() {
        _users = users;
      });

      if (_users.isEmpty) {
        print("Không tìm thấy người dùng phù hợp.");
      }
    } catch (e) {
      print("Lỗi khi tìm kiếm người dùng: $e");
    }
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;

    try {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Friend request sent to $receiverId!");
    } catch (e) {
      print("Error sending friend request: $e");
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;

    try {
      // Remove the friend request
      await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).delete();

      // Add to both users' friend lists
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'friend_list': FieldValue.arrayUnion([senderId])
      });

      await FirebaseFirestore.instance.collection('users').doc(senderId).update({
        'friend_list': FieldValue.arrayUnion([currentUserId])
      });

      print("Accepted friend request from $senderId!");
      _fetchFriendRequests(); // Refresh UI after accepting
    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFC5E8FF)],
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
                      Expanded(
                        child: _isSearching ? _buildUserList() : _buildFriendRequests(),
                      ),
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
    return const Text(
      'Connect with Friends',
      style: TextStyle(
        color: Color(0xFF202244),
        fontSize: 21,
        fontFamily: 'Jost',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search user ID or username'),
              onChanged: (value) {
                setState(() => _isSearching = value.isNotEmpty);
                _fetchUsers(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () => _fetchUsers(_searchController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return _users.isEmpty
        ? const Center(child: Text('No users found'))
        : ListView.builder(
      itemCount: _users.length,
      itemBuilder: (_, index) => _buildUserItem(_users[index]),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['avatar'].isNotEmpty
              ? NetworkImage(user['avatar'])
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          radius: 25,
        ),
        title: Text(user['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: ElevatedButton(
          onPressed: () => _sendFriendRequest(user['id']),
          child: const Text("Add Friend"),
        ),
      ),
    );
  }
}
