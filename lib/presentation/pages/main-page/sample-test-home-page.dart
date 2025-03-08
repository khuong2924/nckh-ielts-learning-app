import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/presentation/model/TestCard.dart'; // Import TestCard
import 'package:auth/presentation/service/SupabaseService.dart'; // Import SupabaseService

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = "";
  int _resultCount = 0;
  List<TestCard> _tests = [];
  List<TestCard> _filteredTests = [];
  bool _isLoading = true;
  String? _errorMessage;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Đặt lại thông báo lỗi
    });

    try {
      final tests = await _supabaseService.fetchTests();
      setState(() {
        _tests = tests.map((e) => TestCard.fromJson(e)).toList();
        _filteredTests = _tests;
        _resultCount = _tests.length;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Error fetching tests: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Dừng trạng thái loading
      });
    }
  }

  void _filterTests(String query) {
    setState(() {
      _currentSearchQuery = query;
      if (query.isEmpty) {
        _filteredTests = _tests;
      } else {
        _filteredTests = _tests
            .where((test) =>
        (test.title?.toLowerCase().contains(query.toLowerCase()) == true ||
            test.title?.toLowerCase().contains(query.toLowerCase()) ==
                true))
            .toList();
      }
      _resultCount = _filteredTests.length;
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
                        SearchResultHeader(
                          searchQuery: _currentSearchQuery,
                          resultCount: _resultCount,
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                            ? Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                          ),
                        )
                            : _filteredTests.isEmpty
                            ? const Center(
                          child: Text(
                            "No tests available",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          itemCount: _filteredTests.length,
                          itemBuilder: (context, index) {
                            final test = _filteredTests[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16.0),
                              child: test,
                            );
                          },
                        ),
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
                _filterTests(value);
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
                _filterTests(_searchController.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}