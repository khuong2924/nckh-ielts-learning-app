import 'package:auth/common/bloc/button/button_state_cubit.dart';
import 'package:auth/common/widgets/button/basic_app_button.dart';
import 'package:auth/presentation/auth/components/SocialLoginButtons.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../common/bloc/button/button_state.dart';
import '../../home/pages/home.dart';
import 'signup.dart';
import '../components/HeaderImage.dart';
import '../components/ForgetPass.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth/common/bloc/button/button_state.dart';
import 'package:auth/common/bloc/button/button_state_cubit.dart';
import 'package:auth/common/widgets/button/basic_app_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../main.dart';
class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();
  bool _obscurePassword = true; // Biến để kiểm soát hiển thị mật khẩu

  @override
  void dispose() {
    _emailCon.dispose();
    _passwordCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ButtonStateCubit(),
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonSuccessState) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (state is ButtonFailureState) {
              var snackBar = SnackBar(content: Text(state.errorMessage));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 100, right: 16, left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const HeaderImage(),
                _signin(),
                const SizedBox(height: 30),
                _emailField(),
                const SizedBox(height: 20),
                _password(),
                const SizedBox(height: 30),
                _createAccountButton(context),
                const SizedBox(height: 20),
                const ForgetPass(),
                const SizedBox(height: 20),
                SocialLoginButtons(),
                const SizedBox(height: 20),
                _signupText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signin() {
    return const Text(
      'Sign In',
      style: TextStyle(
        color: Color(0xff2A4ECA),
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailCon,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
      ),
    );
  }

  Widget _password() {
    return TextField(
      controller: _passwordCon,
      obscureText: _obscurePassword, // Sử dụng biến để điều khiển hiển thị mật khẩu
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword; // Đảo ngược trạng thái khi nhấn nút
            });
          },
        ),
      ),
    );
  }

  Widget _createAccountButton(BuildContext context) {
    return Builder(
      builder: (context) {
        return BasicAppButton(
          title: 'Login',
          onPressed: () async {
            String email = _emailCon.text.trim();
            String password = _passwordCon.text;

            if (email.isEmpty || !email.contains('@')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid email.')),
              );
              return;
            }
            if (password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password cannot be empty.')),
              );
              return;
            }

            // Trigger login logic using Firebase Authentication
            try {
              UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );

              // Nếu đăng nhập thành công, cập nhật trạng thái của ButtonStateCubit
              context.read<ButtonStateCubit>().emit(ButtonSuccessState());
            } on FirebaseAuthException catch (e) {
              String errorMessage = 'An error occurred';
              if (e.code == 'user-not-found') {
                errorMessage = 'No user found for that email.';
              } else if (e.code == 'wrong-password') {
                errorMessage = 'Wrong password provided for that user.';
              }
              context.read<ButtonStateCubit>().emit(ButtonFailureState(errorMessage: errorMessage));
            }
          },
        );
      },
    );
  }

  Widget _signupText(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: Color(0xff3B4054),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
              color: Color(0xff3461FD),
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage(),)
                );
              },
          ),
        ],
      ),
    );
  }
}