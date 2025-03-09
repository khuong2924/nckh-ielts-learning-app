import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/presentation/model/TestCard.dart';
import 'package:auth/presentation/service/SupabaseService.dart';

// Enhanced SearchResultHeader Widget
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
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              searchQuery.isEmpty ? 'All Tests' : 'Result for "$searchQuery"',
              style: const TextStyle(
                color: Color(0xFF202244),
                fontSize: 16,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0961F5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$resultCount FOUND',
              style: const TextStyle(
                color: Color(0xFF0961F5),
                fontSize: 12,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w800,
              ),
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = "";
  int _resultCount = 0;
  List<TestCard> _tests = [];
  List<TestCard> _filteredTests = [];
  bool _isLoading = true;
  String? _errorMessage;
  final SupabaseService _supabaseService = SupabaseService();
  
  // Animation controller for search bar
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchTests();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        _isLoading = false;
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
                child: RefreshIndicator(
                  onRefresh: _fetchTests,
                  color: const Color(0xFF0961F5),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                          const SizedBox(height: 16),
                          _buildTestsList(),
                          // Add extra space at bottom for better scrolling
                          const SizedBox(height: 16),
                        ],
                      ),
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
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              const Icon(
                Icons.book_outlined, 
                color: Color.fromARGB(255, 55, 102, 182), 
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Sample Tests',
                style: TextStyle(
                  color: Color(0xFF202244),
                  fontSize: 24,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          height: 60,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              )
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(
                Icons.search,
                color: Color(0xFFB4BDC4),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search for tests',
                    hintStyle: TextStyle(
                      color: Color(0xFFB4BDC4),
                      fontSize: 16,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onChanged: _filterTests,
                  style: const TextStyle(
                    color: Color(0xFF202244),
                    fontSize: 16,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFB4BDC4),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filterTests("");
                    });
                  },
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _searchController.text.isEmpty ? 50 : 50,
                height: 40,
                margin: const EdgeInsets.only(right: 10),
                decoration: ShapeDecoration(
                  color: const Color(0xFF0961F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF0961F5).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    _filterTests(_searchController.text);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0961F5)),
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0961F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_filteredTests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Icon(
                Icons.search_off,
                color: Color(0xFFB4BDC4),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                "No tests found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202244),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentSearchQuery.isEmpty
                    ? "Try again later or refresh the page"
                    : "Try with different keywords",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTests.length,
      itemBuilder: (context, index) {
        final test = _filteredTests[index];
        // Apply staggered animation to list items
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.4 + (index / _filteredTests.length) * 0.6,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.4 + (index / _filteredTests.length) * 0.6,
                  1.0,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: test,
            ),
          ),
        );
      },
    );
  }
}