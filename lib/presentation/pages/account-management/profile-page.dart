import 'package:flutter/material.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Profile tab

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
              // Fixed CustomAppBar
              CustomAppBar(
                onNotificationTap: () {
                  // Handle notification
                },
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileHeader(),
                      ProfileForm(),
                      ActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Fixed BottomNavBar
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

class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tên người dùng',
            style: TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Vinh Khuong',
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 48,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Chỉnh sửa thông tin cá nhân của bạn tại đây',
            style: TextStyle(
              color: Color(0xFF757575),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ProfileFormField(
            label: 'Giới tính',
            value: 'Nữ',
            hasDropdown: true,
          ),
          ProfileFormField(
            label: 'Ngày sinh',
            value: '10/06/2024',
            isDate: true,
          ),
          ProfileFormField(
            label: 'Email',
            value: 'abc@gmail.com',
          ),
          ProfileFormField(
            label: 'Số điện thoại',
            value: '123123',
          ),
          ProfileFormField(
            label: 'Mục tiêu',
            value: '7.0+',
          ),
        ],
      ),
    );
  }
}

class ProfileFormField extends StatefulWidget {
  final String label;
  final String value;
  final bool hasDropdown;
  final bool isDate;

  const ProfileFormField({
    Key? key,
    required this.label,
    required this.value,
    this.hasDropdown = false,
    this.isDate = false,
  }) : super(key: key);

  @override
  _ProfileFormFieldState createState() => _ProfileFormFieldState();
}

class _ProfileFormFieldState extends State<ProfileFormField> {
  late TextEditingController _controller;
  late String currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        currentValue = "${picked.day}/${picked.month}/${picked.year}";
        _controller.text = currentValue;
      });
    }
  }

  Future<void> _selectGender(BuildContext context) async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Chọn giới tính'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Nam'),
              child: const Text('Nam'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Nữ'),
              child: const Text('Nữ'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Khác'),
              child: const Text('Khác'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        currentValue = result;
        _controller.text = currentValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (widget.isDate) {
                _selectDate(context);
              } else if (widget.hasDropdown) {
                _selectGender(context);
              } else {
                _showEditDialog(context);
              }
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentValue,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (widget.hasDropdown) const Icon(Icons.arrow_drop_down),
                  if (widget.isDate) const Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa ${widget.label}'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Nhập ${widget.label.toLowerCase()}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentValue = _controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}

class ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle save changes
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2C2C),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lưu thay đổi',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: const Text('Quên mật khẩu'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle delete account
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDE412E),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Xóa tài khoản',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}