import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/Vocabulary.dart';

class AddVocabularyDialog extends StatefulWidget {
  final String topicId;
  final String userId;
  final Vocabulary? existingVocabulary;

  const AddVocabularyDialog({
    required this.topicId,
    required this.userId,
    this.existingVocabulary, // ✅ Thêm dòng này
  });
  @override
  _AddVocabularyDialogState createState() => _AddVocabularyDialogState();
}

class _AddVocabularyDialogState extends State<AddVocabularyDialog> {
  late final TextEditingController _wordController;
  late final TextEditingController _pronunciationController;
  late final TextEditingController _meaningController;
  late final TextEditingController _partOfSpeechController;
  late final TextEditingController _synonymsController;
  late final TextEditingController _antonymsController;

  @override
  void initState() {
    super.initState();
    final vocab = widget.existingVocabulary;

    _wordController = TextEditingController(text: vocab?.englishWord ?? '');
    _pronunciationController = TextEditingController(text: vocab?.pronunciation ?? '');
    _meaningController = TextEditingController(text: vocab?.meaning ?? '');
    _partOfSpeechController = TextEditingController(text: vocab?.partOfSpeech ?? '');
    _synonymsController = TextEditingController(text: vocab?.synonyms?.join(', ') ?? '');
    _antonymsController = TextEditingController(text: vocab?.antonyms?.join(', ') ?? '');
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Vocabulary'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_wordController, 'Word'),
            _buildTextField(_pronunciationController, 'Pronunciation'),
            _buildTextField(_meaningController, 'Meaning'),
            _buildTextField(_partOfSpeechController, 'Part of Speech'),
            _buildTextField(_synonymsController, 'Synonyms (comma separated)'),
            _buildTextField(_antonymsController, 'Antonyms (comma separated)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAdd,
          child: _isLoading
              ? const SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _handleAdd() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final inserted = await createVocabularyPipeline(
        word: word,
        flashcardId: widget.topicId,
        userId: widget.userId,
        pronunciation: _pronunciationController.text.trim(),
        meaning: _meaningController.text.trim(),
        partOfSpeech: _partOfSpeechController.text.trim(),
        synonyms: _synonymsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        antonyms: _antonymsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      );

      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(word);

      Navigator.pop(context, true);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create word')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> createVocabularyPipeline({
    required String word,
    required String flashcardId,
    required String userId,
    required String pronunciation,
    required String meaning,
    required String partOfSpeech,
    required List<String> synonyms,
    required List<String> antonyms,
  }) async {
    final rawImage = await generateImageFromFlux(word);
    if (rawImage == null) return null;

    final squareImage = await cropToSquare(rawImage);
    final imageUrl = await uploadToCloudinary(squareImage, 'image');

    final inserted = await Supabase.instance.client
        .from('flashcard_words')
        .insert({
      'flashcard_id': flashcardId,
      'create_by': userId,
      'word': word,
      'image_url': imageUrl,
      'audio_url': '',
      'pronunciation': pronunciation,
      'meaning': meaning,
      'part_of_speech': partOfSpeech,
      'synonyms': synonyms,
      'antonyms': antonyms,
    })
        .select()
        .single();
// 🔥 Tăng total_words trong bảng flashcards
    await Supabase.instance.client
        .rpc('increment_flashcard_total_words', params: {
      'fid': flashcardId,
    });

    return inserted;
  }

  Future<Uint8List?> generateImageFromFlux(String prompt) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-schnell');
    final headers = {
      'Authorization': 'Bearer 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',
      'Content-Type': 'application/json',
    };
    final response = await http.post(url, headers: headers, body: jsonEncode({'inputs': prompt}));
    return response.statusCode == 200 ? response.bodyBytes : null;
  }

  Future<Uint8List> cropToSquare(Uint8List imageBytes) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final size = image.width < image.height ? image.width : image.height;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final src = Rect.fromLTWH((image.width - size) / 2, (image.height - size) / 2, size.toDouble(), size.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    canvas.drawImageRect(image, src, dst, Paint());
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(size, size);
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<String> uploadToCloudinary(Uint8List bytes, String resourceType) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/dlzeg5pet/$resourceType/upload'),
    )
      ..fields['upload_preset'] = 'ml_default'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'upload.${resourceType == "image" ? "png" : "mp3"}',
      ));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final json = jsonDecode(resStr);

    if (response.statusCode == 200) {
      return json['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed: ${json['error']['message']}');
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _pronunciationController.dispose();
    _meaningController.dispose();
    _partOfSpeechController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}

