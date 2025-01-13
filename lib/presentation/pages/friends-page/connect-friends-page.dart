import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class ConnectFriendPage extends StatefulWidget {
  const ConnectFriendPage({super.key});

  @override
  State<ConnectFriendPage> createState() => _ConnectFriendPageState();
}

class _ConnectFriendPageState extends State<ConnectFriendPage> {
  final TextEditingController _searchController = TextEditingController();

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
                        child: _buildUserList(),
                      ),
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
    return const Text(
      'Connect Friend',
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 42),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search id người dùng',
                hintStyle: TextStyle(
                  color: Color(0xFFB4BDC4),
                  fontSize: 16,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0961F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // Handle search
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.separated(
      itemCount: 5, // số lượng user
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFB4BDC4),
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        return _buildUserItem();
      },
    );
  }

  Widget _buildUserItem() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 48,
                decoration: ShapeDecoration(
                  shape: OvalBorder(
                    side: BorderSide(width: 1, color: Color(0xFF0067AC)),
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 6,
                child: Container(
                  width: 36,
                  height: 37,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://s3-alpha-sig.figma.com/img/b1d3/043c/8ead60558de8c20583a7767f336f70e5?Expires=1737331200&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=QpXFa64c9QjJEFyUsh8dwUPd7NJJUvHUxBACidz8DAolk5aBXEcn3dXfRV1pVjze~fFjL63gfbictTfcIndxMzgh-7jomOch92jCfz3myeDh~OEXU7tv7xtaUko7zwxbyZHUWxh2oH1Jz4lb2hnFtJQLi63UdHqiXEK~y5OQOUjzh2c4KYsai9~kSrnxNFLA2Bq-qZkLpJF6lV5ipJbvZUBi~VTLsHHIWE~3M-EwMAIVHiQTqBx4gRMySat9svY1EwEIPh7s8-O49xDW4yLlL5Czml~M9E0U25kiwpdj0~TwECwJ9yy3a-8ES0V5qHT-UxUmf-L2rC6xED19MOFOJw__"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User A',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'ID: 2408',
                style: TextStyle(
                  color: Color(0xFF0067AC),
                  fontSize: 9,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Bank: 8.0',
                style: TextStyle(
                  color: Color(0xFF0067AC),
                  fontSize: 9,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Handle add friend
            },
            child: Text(
              'Add friend',
              style: TextStyle(
                color: Color(0xFF0067AC),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}