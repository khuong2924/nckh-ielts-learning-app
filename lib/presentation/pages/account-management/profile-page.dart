import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';

import 'package:auth/presentation/pages/account-management/signin.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Profile tab
  Map<String, dynamic> userData = {}; // To hold user data
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page initializes
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Use user.uid to get the current user's data
            .get();
        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    } else {
      // Handle case when user is not signed in
      print("No user signed in.");
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(userData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      } catch (e) {
        print("Error updating user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating profile!')));
      }
    }
  }
  Future<void> _confirmDeleteAccount() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa tài khoản'),
          content: const Text('Bạn có chắc chắn muốn xóa tài khoản của mình không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteAccount(); // Gọi hàm xóa tài khoản nếu người dùng xác nhận
    }
  }
  Future<void> _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Xóa dữ liệu người dùng từ Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        // Xóa tài khoản người dùng từ Firebase Authentication
        await user.delete();
        // Đăng xuất người dùng
        await _auth.signOut();

        // Hiển thị hộp thoại thông báo
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Thành công'),
              content: const Text('Tài khoản của bạn đã được xóa thành công.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SigninPage()));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print("Error deleting account: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi xóa tài khoản!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userData.isEmpty // Hiển thị chỉ báo tải khi dữ liệu đang được tải
          ? Center(child: CircularProgressIndicator())
          : Container(
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
              // CustomAppBar cố định
              CustomAppBar(
                onNotificationTap: () {
                  // Xử lý thông báo
                },
              ),

              // Nội dung cuộn
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileHeader(name: userData['username'] ?? ''),
                      ProfileForm(
                        userData: userData,
                        onUpdate: (updatedData) {
                          setState(() {
                            userData = updatedData;
                          });
                        },
                      ),
                      ActionButtons(
                        onSave: _updateUserData,
                        onDelete: _confirmDeleteAccount, // Truyền hàm xác nhận xóa
                      ), // Gọi ActionButtons ở đây
                    ],
                  ),
                ),
              ),

              // BottomNavBar cố định
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
  final String name;

  const ProfileHeader({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tên người dùng',
            style: TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name, // Display user's name
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 48,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
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
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onUpdate;

  const ProfileForm({Key? key, required this.userData, required this.onUpdate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ProfileFormField(
            label: 'Giới tính',
            value: userData['gender'] ?? '',
            hasDropdown: true,
            onChanged: (newValue) {
              userData['gender'] = newValue; // Update gender locally
              onUpdate(userData); // Notify parent about the update
            },
          ),
          ProfileFormField(
            label: 'Ngày sinh',
            value: userData['birthDate'] ?? '',
            isDate: true,
            onChanged: (newValue) {
              userData['birthDate'] = newValue; // Update birth date locally
              onUpdate(userData); // Notify parent about the update
            },
          ),
          ProfileFormField(
            label: 'Email',
            value: userData['email'] ?? '', // Display the email
            readOnly: true, // Email field should be read-only
          ),
          ProfileFormField(
            label: 'Số điện thoại',
            value: userData['phone'] ?? '',
            onChanged: (newValue) {
              userData['phone'] = newValue; // Update phone locally
              onUpdate(userData); // Notify parent about the update
            },
          ),
          ProfileFormField(
            label: 'Mục tiêu',
            value: userData['goal'] ?? '',
            onChanged: (newValue) {
              userData['goal'] = newValue; // Update goal locally
              onUpdate(userData); // Notify parent about the update
            },
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
  final bool readOnly;
  final Function(String)? onChanged;

  const ProfileFormField({
    Key? key,
    required this.label,
    required this.value,
    this.hasDropdown = false,
    this.isDate = false,
    this.readOnly = false,
    this.onChanged,
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
        if (widget.onChanged != null) {
          widget.onChanged!(currentValue); // Notify parent of change
        }
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
        if (widget.onChanged != null) {
          widget.onChanged!(currentValue); // Notify parent of change
        }
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
            onTap: widget.readOnly ? null : () {
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
                  if (!widget.readOnly) const Icon(Icons.edit), // Show edit icon for editable fields
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    if (widget.readOnly) return; // Prevent showing dialog if read-only
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
                if (widget.onChanged != null) {
                  widget.onChanged!(currentValue); // Notify parent of change
                }
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
  final Future<void> Function() onSave;
  final Future<void> Function() onDelete; // Thêm tham số cho hàm xóa

  const ActionButtons({
    Key? key,
    required this.onSave,
    required this.onDelete, // Nhận hàm xóa
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onSave,
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
                  onPressed: onDelete, // Gọi hàm xóa
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