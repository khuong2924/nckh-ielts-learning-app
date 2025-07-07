import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/Vocabulary.dart';

class VocabularyItem extends StatelessWidget {
  final Vocabulary vocabulary;
  final bool canEdit; // 👈 THÊM DÒNG NÀY
  final Future<void> Function(bool)? onLearningStatusChanged;
  final Future<void> Function(bool)? onFavoriteChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VocabularyItem({
    Key? key,
    required this.vocabulary,
    required this.canEdit, // 👈 THÊM DÒNG NÀY
    this.onLearningStatusChanged,
    this.onFavoriteChanged,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Từ vựng tiếng Anh
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                vocabulary.englishWord,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // View Button
          Container(width: 1, height: double.infinity, color: Color(0xFF0067AC)),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () => _showVocabularyDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0067AC),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "View",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Nút yêu thích
          IconButton(
            icon: Icon(
              vocabulary.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Color(0xFF0067AC),
            ),
            onPressed: () async {
              if (onFavoriteChanged != null) {
                await onFavoriteChanged!(!vocabulary.isFavorite);
              }
            },
          ),

          // Nút đã học
          IconButton(
            icon: Icon(
              vocabulary.isLearned ? Icons.check_circle : Icons.check_circle_outline,
              color: Color(0xFF0067AC),
            ),
            onPressed: () async {
              if (onLearningStatusChanged != null) {
                await onLearningStatusChanged!(!vocabulary.isLearned);
              }
            },
          ),

          // ✅ Thêm nút sửa và xóa nếu được phép
          if (canEdit) ...[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
  void _showVocabularyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF0067AC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF0067AC).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.language, color: Color(0xFF0067AC)),
                      SizedBox(width: 10),
                      Text(
                        'Vocabulary Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔽 Hình ảnh nếu có
                if (vocabulary.imageUrl != null && vocabulary.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vocabulary.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),

                // 🔽 Thông tin chi tiết
                _buildDetailRow('Word', vocabulary.englishWord),
                _buildDetailRow('Meaning', vocabulary.meaning),
                if (vocabulary.pronunciation != null && vocabulary.pronunciation!.isNotEmpty)
                  _buildDetailRow('Pronunciation', "/${vocabulary.pronunciation}/"),
                if (vocabulary.partOfSpeech != null && vocabulary.partOfSpeech!.isNotEmpty)
                  _buildDetailRow('Part of Speech', vocabulary.partOfSpeech!),
                if (vocabulary.example != null && vocabulary.example!.isNotEmpty)
                  _buildDetailRow('Example', '"${vocabulary.example!}"'),
                if (vocabulary.synonyms != null && vocabulary.synonyms!.isNotEmpty)
                  _buildDetailRow('Synonyms', vocabulary.synonyms!.join(', ')),
                if (vocabulary.antonyms != null && vocabulary.antonyms!.isNotEmpty)
                  _buildDetailRow('Antonyms', vocabulary.antonyms!.join(', ')),

                const SizedBox(height: 20),

                // Nút Close
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Color(0xFF0067AC),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),

                if (canEdit)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF0067AC)),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) onEdit!();
                      if (value == 'delete' && onDelete != null) onDelete!();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}