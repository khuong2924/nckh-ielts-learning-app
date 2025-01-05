import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/TestCard.dart';

// SearchResultHeader Widget
class SearchResultHeader extends StatelessWidget {
  final String searchQuery;
  final int resultCount;

  const SearchResultHeader({
    Key? key,
    this.searchQuery = "",
    this.resultCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Result for "$searchQuery"',
            style: const TextStyle(
              color: Color(0xFF202244),
              fontSize: 15,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$resultCount FOUNDS',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0961F5),
              fontSize: 12,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class SampleTestHomePage extends StatefulWidget {
  const SampleTestHomePage({super.key});

  @override
  _SampleTestHomePageState createState() => _SampleTestHomePageState();
}

class _SampleTestHomePageState extends State<SampleTestHomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = "";
  int _resultCount = 0;

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
              CustomAppBar(
                onNotificationTap: () {
                  // Handle notification
                },
              ),

              Expanded(
                child: SingleChildScrollView(
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
                        // Add SearchResultHeader here
                        SearchResultHeader(
                          searchQuery: _currentSearchQuery,
                          resultCount: _resultCount,
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TestCard(
                                title: 'IELTS Test 1',
                                description: 'Practice test for IELTS examination',
                                onTap: () {
                                  // when click...

                                },
                              ),
                            );
                          },
                        )

                        // Add more content here
                      ],
                    ),
                  ),
                ),
              ),

              BottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      child: const Text(
        'Sample Test',
        style: TextStyle(
          color: Color(0xFF202244),
          fontSize: 21,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 64,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 12,
            offset: Offset(0, 3),
            spreadRadius: 0,
          )
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
                hintText: 'Search đề bài',
                hintStyle: TextStyle(
                  color: Color(0xFFB4BDC4),
                  fontSize: 16,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w700,
                ),
              ),
              onChanged: (value) {
                // Optional: update search results as user types
                setState(() {
                  _currentSearchQuery = value;
                });
              },
            ),
          ),
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 10),
            decoration: ShapeDecoration(
              color: const Color(0xFF0961F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // Handle search and update results
                setState(() {
                  _currentSearchQuery = _searchController.text;
                  // Simulate finding results - replace with actual search logic
                  _resultCount = 24; // Example count
                });
              },
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