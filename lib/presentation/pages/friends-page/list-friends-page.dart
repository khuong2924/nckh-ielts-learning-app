import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();

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
              BottomNavBar(
                currentIndex: 3,
                onTap: (index) {
                  // Handle navigation
                },
              ),
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
        Container(

          child: IconButton(
            icon: Image.asset(
              'lib/icons/ic-add.png',
              width: 32,
              height: 32,
            ),
            onPressed: () {

            },
          ),
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
          side: const BorderSide(
            color: Color(0xAF4681DA),
          ),
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
                hintStyle: TextStyle(
                  color: Color(0xFF49454F),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10, // Số lượng bạn bè
        itemBuilder: (context, index) {
          return _buildFriendItem();
        },
      ),
    );
  }

  Widget _buildFriendItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          _buildAvatarWithBorder(),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Friend Name',
                style: TextStyle(
                  color: Color(0xFF49454F),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'What should we make?',
                style: TextStyle(
                  color: Color(0xFF49454F),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithBorder() {
    return Container(
      width: 50,
      height: 50,
      decoration: ShapeDecoration(
        shape: OvalBorder(
          side: BorderSide(width: 1, color: Color(0xFF0067AC)),
        ),
      ),
      child: ClipOval(
        child: Image.network(
          "https://s3-alpha-sig.figma.com/img/b1d3/043c/8ead60558de8c20583a7767f336f70e5?Expires=1737331200&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=QpXFa64c9QjJEFyUsh8dwUPd7NJJUvHUxBACidz8DAolk5aBXEcn3dXfRV1pVjze~fFjL63gfbictTfcIndxMzgh-7jomOch92jCfz3myeDh~OEXU7tv7xtaUko7zwxbyZHUWxh2oH1Jz4lb2hnFtJQLi63UdHqiXEK~y5OQOUjzh2c4KYsai9~kSrnxNFLA2Bq-qZkLpJF6lV5ipJbvZUBi~VTLsHHIWE~3M-EwMAIVHiQTqBx4gRMySat9svY1EwEIPh7s8-O49xDW4yLlL5Czml~M9E0U25kiwpdj0~TwECwJ9yy3a-8ES0V5qHT-UxUmf-L2rC6xED19MOFOJw__",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}