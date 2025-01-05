import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  int _currentIndex = 3;
  bool _isChecked = false;

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
              CustomAppBar(
                onNotificationTap: () {
                  // Handle notification
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ComplaintForm(
                      isChecked: _isChecked,
                      onCheckChanged: (value) {
                        setState(() {
                          _isChecked = value;
                        });
                      },
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
}

class ComplaintForm extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onCheckChanged;

  const ComplaintForm({
    Key? key,
    required this.isChecked,
    required this.onCheckChanged,
  }) : super(key: key);

  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _nameController = TextEditingController();
  final _problemDetailController = TextEditingController();
  String _selectedProblemType = 'Select problem type';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFormField(
            label: 'Full Name',
            controller: _nameController,
            hintText: 'Enter your full name',
          ),
          const SizedBox(height: 16),
          _buildProblemTypeDropdown(),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Problem detail',
            controller: _problemDetailController,
            hintText: 'Describe your problem',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildCheckboxSection(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Complaint',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Please tell us your problem',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblemTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problem Type',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedProblemType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
          items: [
            'Select problem type',
            'Technical Issue',
            'Account Problem',
            'Other',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedProblemType = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxSection() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.isChecked,
              onChanged: (bool? value) {
                widget.onCheckChanged(value!); // Cập nhật giá trị checkbox
              },
            ),
            const Text("I'm sure this is real"),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 32),
          child: Text(
            'Read our T&Cs',
            style: TextStyle(
              color: Color(0xFF757575),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isChecked ? _submitComplaint : null, // Chỉ cho phép gửi khi isChecked là true
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isChecked ? const Color(0xFF2C2C2C) : Colors.grey, // Thay đổi màu nút nếu không được phép
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Send this complaint',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }


  void _submitComplaint() async {
    if (_nameController.text.isEmpty || _problemDetailController.text.isEmpty ||
        _selectedProblemType == 'Select problem type') {
      // Hiển thị thông báo lỗi nếu các trường không hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Lấy thông tin người dùng đang đăng nhập
    User? user = FirebaseAuth.instance.currentUser;

    // Tạo một bản ghi mới trong Firestore
    try {
      await FirebaseFirestore.instance.collection('complaints').add({
        'user_id': user?.uid, // Lưu ID người dùng
        'name': _nameController.text,
        'problem_detail': _problemDetailController.text,
        'problem_type': _selectedProblemType,
        'is_checked': widget.isChecked,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint submitted successfully!')),
      );

      // Xóa dữ liệu sau khi gửi
      _nameController.clear();
      _problemDetailController.clear();
      setState(() {
        _selectedProblemType = 'Select problem type';
        widget.onCheckChanged(false); // Reset checkbox
      });
    } catch (e) {
      print('Error submitting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit complaint')),
      );
    }
  }
}