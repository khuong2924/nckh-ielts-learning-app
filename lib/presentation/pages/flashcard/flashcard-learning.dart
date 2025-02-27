import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import '../../model/Flashcards.dart';
import '../../model/Vocabulary.dart';

class FlashcardLearning extends StatefulWidget {
  final String flashcardId;

  const FlashcardLearning({Key? key, required this.flashcardId}) : super(key: key);

  @override
  State<FlashcardLearning> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardLearning>
    with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentWordIndex = 0;
  late Flashcard _flashcard;
  List<Vocabulary> words = [];
  int userProgress = 0;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadFlashcardData(widget.flashcardId);

    // Add keyboard listener for desktop shortcuts
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _handleBack();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _handleNext();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _flipCard();
      } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
        _handlePronunciation();
      }
    }
  }

  Future<void> _handlePronunciation() async {
    if (words.isEmpty) return;

    final word = words[currentWordIndex].englishWord;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(word);
  }

  Future<void> _loadFlashcardData(String flashcardId) async {
    try {
      final response = await Supabase.instance.client
          .from('flashcards')
          .select()
          .eq('id', flashcardId)
          .single();

      if (response != null) {
        final flashcard = response;

        setState(() {
          _flashcard = Flashcard(
            id: flashcard['id'],
            topic: flashcard['topic'],
            totalWords: flashcard['total_words'],
            createdAt: DateTime.parse(flashcard['created_at']),
          );
        });

        await _loadVocabulary();
      } else {
        print('No flashcard found with the given ID.');
      }
    } catch (e) {
      print('Error loading flashcard data: $e');
    }
  }

  Future<void> _loadVocabulary() async {
    try {
      final response = await Supabase.instance.client
          .from('flashcard_words')
          .select()
          .eq('flashcard_id', _flashcard.id);

      if (response != null && response is List) {
        final List<Vocabulary> loadedWords = response
            .map((item) => Vocabulary.fromMap(item))
            .toList();

        setState(() {
          words = loadedWords;
        });
      } else {
        print('No vocabulary found for this flashcard.');
      }
    } catch (e) {
      print('Error fetching vocabulary: $e');
    }
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _flipCard() {
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _handleNext() {
    if (currentWordIndex < words.length - 1) {
      setState(() {
        currentWordIndex++;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  void _handleBack() {
    if (currentWordIndex > 0) {
      setState(() {
        currentWordIndex--;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  Widget _buildProgressSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$userProgress/${_flashcard.totalWords}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0067AC),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: userProgress / _flashcard.totalWords,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(Vocabulary word) {

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isDesktop = MediaQuery.of(context).size.width > 900;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(3.14159 * _animation.value),
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF5FBFF)],
                ),
                borderRadius: BorderRadius.circular(isDesktop ? 32 : 20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0067AC).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Color(0xFF0067AC).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 40 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isDesktop ? 'FLASHCARD' : 'CARD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Color(0xFF0067AC).withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 30 : 20),
                      _animation.value < 0.5
                          ? Text(
                        word.englishWord,
                        style: TextStyle(
                          fontSize: isDesktop ? 60 : 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                        textAlign: TextAlign.center,
                      )
                          : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: Text(
                          word.vietnameseWord,
                          style: TextStyle(
                            fontSize: isDesktop ? 60 : 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0067AC),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 40 : 20),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF0067AC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.volume_up,
                            color: Color(0xFF0067AC),
                            size: 30,
                          ),
                          onPressed: _handlePronunciation,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 30 : 10),
                      if (isDesktop)
                        Text(
                          'Click to flip',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordDetailsCard(Vocabulary word) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần hình ảnh vuông - desktop
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFEEEEEE)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.network(
                      word.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 24),

                // Pronunciation và thông tin chi tiết - desktop
                Expanded(
                  child: Container(
                    height: 250,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5FBFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFDDEEFA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(0xFF0067AC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  color: Color(0xFF0067AC),
                                  size: 24,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: _handlePronunciation,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFFE5E5E5)),
                          ),
                          child: Text(
                            word.pronunciation ?? 'N/A',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        Spacer(),

                      ],
                    ),
                  ),
                ),
              ],
            )
          else
          // Mobile layout
            Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFEEEEEE)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        word.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Phần pronunciation cho mobile
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FBFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFDDEEFA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pronunciation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0067AC),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF0067AC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.volume_up,
                                color: Color(0xFF0067AC),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: _handlePronunciation,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(0xFFE5E5E5)),
                        ),
                        child: Text(
                          word.pronunciation ?? 'N/A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      SizedBox(height: 12),


                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

// Widget hiển thị pill thông tin thay vì _buildWordInfoChip
  Widget _buildInfoPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFE1F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0067AC),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Vocabulary word) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            word.meaning ?? 'N/A',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.grey[600],
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardShortcutInfo(String key, String action) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFEEF7FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Color(0xFFCCE4F7)),
            ),
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0067AC),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            action,
            style: TextStyle(
              color: Color(0xFF5A5A5A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: _handleBack,
          icon: Icon(Icons.arrow_back_rounded),
          label: Text(''),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0067AC),
            elevation: 0,
            side: BorderSide(color: Color(0xFF0067AC)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _handleNext,
          icon: Icon(Icons.arrow_forward_rounded),
          label: Text(''),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0067AC),
            elevation: 0,
            side: BorderSide(color: Color(0xFF0067AC)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Vocabulary currentWord) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar for desktop with progress and navigation controls
        Container(
          width: 280,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(1, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressSection(),
              SizedBox(height: 24),
              Text(
                'Thanh điều hướng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202244),
                ),
              ),
              SizedBox(height: 16),
              _buildDesktopNavigationControls(),
              SizedBox(height: 24),
              SizedBox(height: 16),
              _buildKeyboardShortcutInfo('← / →', 'Previous / Next'),
              _buildKeyboardShortcutInfo('Space', 'Flip Card'),
              _buildKeyboardShortcutInfo('P', 'Pronounce'),
              Spacer(),
              Text(
                'Word ${currentWordIndex + 1} of ${words.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0067AC),
                ),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    // On desktop, put flashcard first with larger size
                    Container(
                      height: 400, // Larger flashcard for desktop
                      margin: EdgeInsets.only(bottom: 32),
                      child: _buildFlashcard(currentWord),
                    ),

                    // Two-column layout for the details on desktop
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildWordDetailsCard(currentWord),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _buildDescriptionCard(currentWord),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Vocabulary currentWord) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressSection(),
            _buildWordDetailsCard(currentWord),
            _buildDescriptionCard(currentWord),
            _buildFlashcard(currentWord),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isDesktop) {
    if (isDesktop) {
      // Desktop doesn't need the bottom navigation controls
      return SizedBox();
    }

    // Return the existing mobile bottom navigation
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, -4),
            blurRadius: 15,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Back
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0067AC), Color(0xFF0088DC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0067AC).withOpacity(0.3),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleBack,
                      borderRadius: BorderRadius.circular(21),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Tap to flip indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0067AC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF0067AC).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFF0067AC),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Tap to flip',
                        style: TextStyle(
                          color: Color(0xFF0067AC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nút Next
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0067AC), Color(0xFF0088DC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0067AC).withOpacity(0.3),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleNext,
                      borderRadius: BorderRadius.circular(21),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            BottomNavBar(currentIndex: 1, onTap: (int) {}),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0067AC)),
          ),
        ),
      );
    }

    final currentWord = words[currentWordIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFFC5E8FF)],
          ),
        ),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  CustomAppBar(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _flashcard.topic,
                                style: TextStyle(
                                  color: Color(0xFF202244),
                                  fontSize: isDesktop ? 28 : 24,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isDesktop)
                                Text(
                                  '${words.length} words • Created on ${_flashcard.createdAt.day}/${_flashcard.createdAt.month}/${_flashcard.createdAt.year}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              color: Color(0xFF0067AC),
                              onPressed: () {},
                              tooltip: 'Add to favorites',
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              color: Color(0xFF0067AC),
                              onPressed: () {},
                              tooltip: 'Share flashcard',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout(currentWord)
                  : _buildMobileLayout(currentWord),
            ),
            _buildBottomSection(isDesktop),
          ],
        ),
      ),
    );
  }
}